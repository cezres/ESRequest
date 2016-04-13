//
//  ESRequest.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/12.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequest.h"
#import "NSString+MD5.h"
#import "NSObject+ViewController.h"
#import "ESRequestManager.h"

@interface ESRequest ()
<ESRequestManagerDelegate>

@end

@implementation ESRequest

#pragma mark - Init
- (instancetype)initWithType:(NSInteger)type; {
    if (self = [super init]) {
        self.type = type;
        _config = [[ESRequestConfigManager sharedInstance] requestConfigForType:@(self.type)];
        self.hiddenHUD = YES;
        self.hudSuperView = self.es_currentViewController.view;
    }
    return self;
}

//- (void)dealloc; {
//    
//    NSLog(@"%s", __FUNCTION__);
//    
//}


+ (ESRequest *)RequestWithType:(NSInteger)type Parameters:(id)parameters Delegate:(id<ESRequestDelegate>)delegate; {
    ESRequest *request        = [[ESRequest alloc] initWithType:type];
    request.delegate          = delegate;
    request.config.parameters = parameters;
    return request;
}

+ (ESRequest *)RequestWithType:(NSInteger)type Parameters:(id)parameters completionBlock:(void (^)(ESRequest * _Nonnull))completionBlock; {
    ESRequest *request        = [[ESRequest alloc] initWithType:type];
    request.completionBlock   = completionBlock;
    request.config.parameters = parameters;
    return request;
}

+ (ESRequest *)RequestHUDWithType:(NSInteger)type Parameters:(id)parameters Delegate:(id<ESRequestDelegate>)delegate; {
    ESRequest *request        = [[ESRequest alloc] initWithType:type];
    request.delegate          = delegate;
    request.config.parameters = [parameters copy];
    request.hiddenHUD         = NO;
    return request;
}

+ (ESRequest *)RequestHUDFromNetworkWithType:(NSInteger)type Parameters:(id)parameters Delegate:(id<ESRequestDelegate>)delegate; {
    ESRequest *request      = [ESRequest RequestHUDWithType:type Parameters:parameters Delegate:delegate];
    request.dataFromNetwork = YES;
    return request;
}

+ (ESRequest *)RequestHUDWithType:(NSInteger)type Parameters:(id)parameters completionBlock:(void (^)(ESRequest * _Nonnull))completionBlock; {
    ESRequest *request        = [[ESRequest alloc] initWithType:type];
    request.completionBlock   = completionBlock;
    request.config.parameters = [parameters copy];
    request.hiddenHUD = NO;
    return request;
}


#pragma mark - Start

- (void)start; {
    if (self.dataFromNetwork == NO) {
        if ([self readCache]) {
            
            
            if ([_delegate respondsToSelector:@selector(requestCompleted:)]) {
                [_delegate requestCompleted:self];
                
            }
            if (self.completionBlock) {
                self.completionBlock(self);
            }
            _error = nil;
            return;
        }
    }
    
    if (!self.hiddenHUD) {
        [self.HUD show:YES];
    }
    
    [[ESRequestManager sharedInstance] sendRequest:self];
    _executing = YES;
}

- (void)stop; {
    self.successCompletionBlock = NULL;
    self.failureCompletionBlock = NULL;
    self.completionBlock = NULL;
    self.delegate = NULL;
}



#pragma mark - ESRequestManagerDelegate
- (void)networkCompleted:(ESRequestManager *)manager responseObject:(id)responseObject error:(NSError *)error; {
    _executing = NO;
    
    
    
    
    if (responseObject) {
        NSLog(@"网络数据: %@", self.config.URLString);
        _responseObject = responseObject;
        _error = error;
        [self saveCache];
    }
    else if (_responseObject) {
        //        NSLog(@"本地过期数据");
    }
    
    if (!self.hiddenHUD) {
        [self.HUD hide:YES];
        
    }
    
    
    
    
    if ([self.responseMsg isEqualToString:@"用户未登录"] ||
        [self.responseMsg isEqualToString:@"账号没有登录"] ||
        [self.responseMsg isEqualToString:@"账号未登录"]) {
        
    }
    
    if (error) {
        _error = error;
    }
    
    if ([_delegate respondsToSelector:@selector(requestCompleted:)]) {
        [_delegate requestCompleted:self];
    }
    if (self.completionBlock) {
        self.completionBlock(self);
    }
    
}

- (void)networkProgress:(ESRequestManager *)manager completedUnitCount:(int64_t)completedUnitCount totalUnitCount:(int64_t)totalUnitCount; {
    if ([self.delegate respondsToSelector:@selector(requestProgress:completedUnitCount:totalUnitCount:)]) {
        [self.delegate requestProgress:self completedUnitCount:completedUnitCount totalUnitCount:totalUnitCount];
    }
}

- (void)networkDownloadCompleted:(ESRequestManager *)manager filePath:(NSURL *)filePath error:(NSError *)error; {
    _executing = NO;
    if (NULL != self.HUD) {
        [self.HUD hide:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(requestDownloadCompleted:filePath:error:)]) {
        [self.delegate requestDownloadCompleted:self filePath:filePath error:error];
    }
}


#pragma mark - Cache
+ (void)removeCahceWithType:(NSInteger)type; {
    [[ESRequestCache sharedInstance] removeCacheObjectForGroup:@(type).stringValue];
}


- (BOOL)readCache; {
    if (self.config.CacheTime > 0) {
        BOOL flag = YES;
        __autoreleasing id response;
        [[ESRequestCache sharedInstance] cacheObjectForToken:self.MD5 Group:@(_type).stringValue TimeoutInterval:_config.CacheTime object:&response flag:&flag];
        if (response) {
            NSLog(@"本地数据");
            _responseObject = response;
        }
        return !flag;
    }
    else {
        return NO;
    }
}

- (void)saveCache; {
    /**
     *  如果必须从网络中获取数据  （刷新）  清理整组数据
     */
    if (self.isDataFromNetwork) {
        [[ESRequestCache sharedInstance] removeCacheObjectForGroup:@(_type).stringValue];
    }
    
    /**
     *  存储新数据
     */
    if (_config.CacheTime > 0 && 1 == self.responseStatusCode) {
        [[ESRequestCache sharedInstance] storeCachedObject:_responseObject Token:self.MD5 Group:@(_type).stringValue];
    }
}

#pragma mark - Property Set/Get

- (NSString *)MD5; {
    return [NSString stringWithFormat:@"%@__%@", self.config.URLString, self.config.parameters].esrequest_MD5;
}

- (NSUInteger)hash; {
    return self.MD5.hash;
}

-(BOOL)isEqual:(id)object; {
    if ([object isMemberOfClass:[ESRequest class]]) {
        if ([self.MD5 isEqualToString:((ESRequest *)object).MD5]) {
            return YES;
        }
    }
    return NO;
}


- (void)setResponseObject:(id)responseObject; {
    _responseObject = responseObject;
}

- (NSInteger)responseStatusCode; {
    return [[_responseObject valueForKey:@"status"] integerValue];
}

- (NSString *)responseMsg; {
    NSString *msg = [_responseObject valueForKey:@"msg"];
    if (NULL != msg) {
        return msg;
    }
    else if (NULL != self.error  && self.error != nil) {
        NSString *str = self.error.userInfo[@"NSLocalizedDescription"];
        if ([str isEqualToString:@"The request timed out."]) {
            return @"请求超时";
        }else if ([str isEqualToString:@"Could not connect to the server."]){
            return @"无法连接服务";
        }else if([str isEqualToString:@"未能连接到服务器。"]){
            return @"未能连接到服务器。";
        }
        
        
        return @"网络请求出错";
    }
    else {
        return @"";
    }
}

- (NSDictionary *)responseData; {
    return [self.responseObject objectForKey:@"data"];
}



- (MBProgressHUD *)HUD; {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.hudSuperView];
        [self.hudSuperView addSubview:_HUD];
        _HUD.labelText = @"Loading";
        _HUD.removeFromSuperViewOnHide = YES;
    }
    return _HUD;
}


#pragma mark - NextPage

- (BOOL)nextPage; {
    if (!self.config.Page) {
        return NO;
    }
    else if (!self.responseObject) {
        return NO;
    }
    else if ([self.nextKeyPath count] == 0) {
        return NO;
    }
    else if (self.next) {
        [self.config nextPage];
        [self start];
        return YES;
    }
    else {
        return NO;
    }
}


- (NSInteger)index; {
    if (!self.config.Page) {
        return -1;
    }
    else if (self.responseObject == nil) {
        return -1;
    }
    else if ([self.nextKeyPath count] == 0) {
        return -1;
    }
    NSDictionary *dict = self.responseObject;
    for (NSString *key in self.nextKeyPath) {
        dict = [self.responseObject objectForKey:key];
    }
    return [[dict objectForKey:@"index"] integerValue];
}



- (NSArray<NSString *> *)nextKeyPath; {
    NSMutableArray *keyPath = [NSMutableArray array];
    [self analysisNextKeyPath:self.responseObject KeyPath:keyPath];
    return keyPath;
}

/**
 *  解析分页数据相关字段路径
 *
 *  @param dict    <#dict description#>
 *  @param keyPath <#keyPath description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)analysisNextKeyPath:(NSDictionary *)dict KeyPath:(NSMutableArray *)keyPath; {
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        if ([key isEqualToString:@"next"]) {
            return YES;
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            [keyPath addObject:key];
            BOOL result = [self analysisNextKeyPath:value KeyPath:keyPath];
            if (result) {
                return  result;
            }
        }
    }
    [keyPath removeLastObject];
    return NO;
}



@end
