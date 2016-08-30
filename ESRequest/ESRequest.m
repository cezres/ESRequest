//
//  ESRequest.m
//  ESRequest
//
//  Created by 翟泉 on 2016/8/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "ESRequestCache.h" // 缓存


NSString * __MD5(NSString *str) {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}
@interface ESRequest ()

@property (strong, nonatomic) NSURLSessionTask *task;

@end

@implementation ESRequest

+ (instancetype)request {
    return [[self alloc] init];
}

- (__kindof ESRequest *)startWithDelegate:(id<RequestDelegate>)delegate {
    _delegate = delegate;
    return [self start];
}

- (__kindof ESRequest *)startWithCompletionBlock:(ESRequestCompletionBlock)completionBlock {
    _completionBlock = completionBlock;
    return [self start];
}

- (__kindof ESRequest *)start {
    [self willStart];
    
    if (self.state == NSURLSessionTaskStateSuspended) {
        [_task resume];
        return self;
    }
    
    _responseObject = NULL;
    _error = NULL;
    _task = NULL;
    
    if (!_mustFromNetwork && [self readCache]) {
        [self.delegate requestCompletion:self];
        _completionBlock ? _completionBlock(self) : NULL;
        _completionBlock = NULL;
    }
    else {
        [self dynamicURLStringWithCallback:^(NSString *URLString, id parameters) {
            _task = [[ESRequestHandler sharedInstance] handleRequestWithURLString:URLString Method:self.method parameters:parameters delegate:self];
        }];
    }
    return self;
}

- (ESRequest *)pause {
    [self.task suspend];
    return self;
}

- (ESRequest *)stop {
    _completionBlock = NULL;
    _delegate = NULL;
    [self.task cancel];
    return self;
}

- (NSURLSessionTaskState)state {
    return _task.state;
}


- (void)willStart {
    
}

- (void)completed {
    [self storeCache];
    
    [self.delegate requestCompletion:self];
    !_completionBlock ?: _completionBlock(self);
    _completionBlock = NULL;
}

#pragma mark - RequestHandlerDelegate

- (void)requestHandleCompletionResponseObject:(id)responseObject error:(NSError *)error {
    _responseObject = responseObject;
    _error = error;
    [self completed];
}



#pragma mark - Cache

- (NSString *)groupName {
    return __MD5(self.URLString);
}

- (NSString *)identifier {
    if (self.parameters) {
        return __MD5(self.parameters.description);
    }
    else {
        return self.groupName;
    }
}

- (void)storeCache {
    if (self.cacheTimeoutInterval <= 0 || !_responseObject) {
        return;
    }
    [[ESRequestCache sharedInstance] storeCachedJSONObjectForRequest:self];
}

- (BOOL)readCache {
    if (self.cacheTimeoutInterval <= 0) {
        return NO;
    }
    BOOL isTimeout;
    id cachedJSONObject = [[ESRequestCache sharedInstance] cachedJSONObjectForRequest:self isTimeout:&isTimeout];
    if (cachedJSONObject && !isTimeout) {
        _responseObject = cachedJSONObject;
        return YES;
    }
    else {
        return NO;
    }
}



#pragma mark - tool

- (void)dynamicURLStringWithCallback:(void (^)(NSString *URLString, id parameters))callback;
{
    if ([self.URLString rangeOfString:@"##"].length <= 0) {
        callback? callback(self.URLString, self.parameters) : NULL;
        return;
    }
    
    if (![self.parameters isKindOfClass:[NSDictionary class]]) {
        callback? callback(self.URLString, self.parameters) : NULL;
        return;
    }
    
    NSDictionary *parameters = (NSDictionary *)self.parameters;
    if ([parameters count] == 0) {
        callback? callback(self.URLString, self.parameters) : NULL;
        return;
    }
    
    NSMutableArray<NSString *> *parameterNames = [NSMutableArray array];
    NSRange range = NSMakeRange(0, self.URLString.length);
    NSInteger start = -1;
    
    while (YES) {
        range = [self.URLString rangeOfString:@"##" options:NSCaseInsensitiveSearch range:range];
        if (range.length > 0) {
            if (start == -1) {
                start = range.location + range.length;
            }
            else {
                [parameterNames addObject:[self.URLString substringWithRange:NSMakeRange(start, range.location - start)]];
                start = -1;
            }
            range.location = range.location + range.length;
            range.length = self.URLString.length - range.location;
        }
        else {
            break;
        }
    }
    
    if (parameterNames.count == 0) {
        callback? callback(self.URLString, self.parameters) : NULL;
        return;
    }
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSString *URLString = self.URLString;
    
    for (NSString *key in parameters.allKeys) {
        for (NSString *name in parameterNames) {
            if ([key isEqualToString:name]) {
                URLString = [URLString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"##%@##", name] withString:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
                [mutableParameters removeObjectForKey:key];
            }
        }
    }
    
    callback? callback(URLString, (mutableParameters.count? mutableParameters : NULL) ) : NULL;
}

@end

