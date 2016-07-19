//
//  Request.m
//  ESRequest
//
//  Created by 翟泉 on 2016/7/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "Request.h"
#import "RequestHandler.h"
#import "RequestCache.h"
#import <CommonCrypto/CommonDigest.h>


NSString * MD5(NSString *str) {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

@interface Request ()

@end

@implementation Request

+ (instancetype)requestWithDelegate:(id<RequestDelegate>)delegate {
    Request *request = [[self alloc] init];
    request.delegate = delegate;
    return request;
}

+ (instancetype)requestWithCompletionBlock:(void (^)(Request *))completionBlock {
    Request *request = [[self alloc] init];
    request.completionBlock = completionBlock;
    return request;
}


- (void)resume {
    _responseObject = NULL;
    
    if ([self readCache]) {
        _completionBlock ? _completionBlock(self) : NULL;
    }
    else {
        [self dynamicURLStringWithCallback:^(NSString *URLString, id parameters) {
            _task = [[RequestHandler sharedInstance] sendRequestWithURLString:URLString Method:self.method parameters:parameters delegate:self];
        }];
    }
}

- (void)suspend {
    [self.task suspend];
}

- (void)cancel {
    _completionBlock = NULL;
    [self.task cancel];
}


- (NSURLSessionTaskState)state {
    return _task.state;
}


#pragma mark - RequestHandlerDelegate

- (void)requestHandlerResponseObject:(id)responseObject {
    NSLog(@"网络");
    _responseObject = responseObject;
    
    [self storeCache];
    
    _completionBlock ? _completionBlock(self) : NULL;
}

- (void)requestHandlerError:(NSError *)error {
    _error = error;
    _completionBlock ? _completionBlock(self) : NULL;
}


#pragma mark - Cache

- (NSString *)groupName {
    return MD5(self.URLString);
}

- (NSString *)identifier {
    if (self.parameters) {
        return MD5(self.parameters.description);
    }
    else {
        return self.groupName;
    }
}

- (void)storeCache {
    if (self.cacheTimeoutInterval <= 0 || !_responseObject) {
        return;
    }
    [[RequestCache sharedInstance] storeCachedJSONObjectForRequest:self];
}

- (BOOL)readCache {
    if (self.cacheTimeoutInterval <= 0) {
        return NO;
    }
    BOOL isTimeout;
    id cachedJSONObject = [[RequestCache sharedInstance] cachedJSONObjectForRequest:self isTimeout:&isTimeout];
    if (cachedJSONObject && !isTimeout) {
        _responseObject = cachedJSONObject;
        NSLog(@"缓存");
        return YES;
    }
    else {
        return NO;
    }
}




- (void)willResume {}

- (void)willReadCache {}

- (BOOL)didReadCache { return YES; }

- (void)completed {}

- (void)success {}

- (void)failure {}

- (BOOL)willStoreCache { return YES; }



#pragma mark - tool

- (void)dynamicURLStringWithCallback:(void (^)(NSString *URLString, id parameters))callback;
{
    if ([self.URLString rangeOfString:@"%%"].length <= 0) {
        return;
    }
    
    if (![self.parameters isKindOfClass:[NSDictionary class]]) {
        callback? callback(self.URLString, self.parameters) : NULL;
        return;
    }
    
    NSDictionary *parameters = (NSDictionary *)self.parameters;
    if ([parameters count] == 0) {
        return;
    }
    
    NSMutableArray<NSString *> *parameterNames = [NSMutableArray array];
    NSRange range = NSMakeRange(0, self.URLString.length);
    NSInteger start = -1;
    
    while (YES) {
        range = [self.URLString rangeOfString:@"%%" options:NSCaseInsensitiveSearch range:range];
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
                URLString = [URLString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%%%%%@%%%%", name] withString:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
                [mutableParameters removeObjectForKey:key];
            }
        }
    }
    
    callback? callback(URLString, (mutableParameters.count? mutableParameters : NULL) ) : NULL;
}

@end
