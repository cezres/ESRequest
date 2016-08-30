//
//  ESRequestHandler.m
//  ESRequest
//
//  Created by 翟泉 on 2016/8/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestHandler.h"
#import "ESRequest.h"
#import <AFNetworking.h>

@interface ESRequestHandler ()

@property(strong, nonatomic, nonnull) AFHTTPSessionManager *HTTPSessionManager;

@end

@implementation ESRequestHandler

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:NULL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [_HTTPSessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
            return [[ESRequestHandler sharedInstance] queryStringSerialization:request parameters:parameters error:error];
        }];
        
    }
    return self;
}

- (NSURLSessionDataTask *)handleRequest:(ESRequest *)request
{
    return [self handleRequestWithURLString:request.URLString Method:request.method parameters:request.parameters delegate:request];
}

- (NSURLSessionDataTask *)handleRequestWithURLString:(NSString *)URLString Method:(ESHTTPMethod)method parameters:(id)parameters delegate:(id<ESRequestHandlerDelegate>)delegate
{
    if (![URLString hasPrefix:@"http"]) {
        URLString = [_baseURLString stringByAppendingPathComponent:URLString];
    }
    if (method == ESHTTPMethodGet) {
        return [_HTTPSessionManager GET:URLString parameters:parameters progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [delegate requestHandleCompletionResponseObject:responseObject error:NULL];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [delegate requestHandleCompletionResponseObject:NULL error:error];
        }];
    }
    else if (method == ESHTTPMethodPost) {
        return [_HTTPSessionManager POST:URLString parameters:parameters progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [delegate requestHandleCompletionResponseObject:responseObject error:NULL];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [delegate requestHandleCompletionResponseObject:NULL error:error];
        }];
    }
    else {
        return NULL;
    }
}

#pragma mark get / set

- (ESNetworkReachabilityStatus)networkReachabilityStatus
{
    return (ESNetworkReachabilityStatus)[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    _timeoutInterval = timeoutInterval;
    _HTTPSessionManager.requestSerializer.timeoutInterval = _timeoutInterval;
}

#pragma mark tool

- (NSString *)queryStringSerialization:(NSURLRequest *)request parameters:(id)parameters error:(NSError *__autoreleasing *)error
{
    NSArray* (^parametersToArray)(NSDictionary *dictionary) = ^(NSDictionary *dictionary) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:dictionary.count];
        for (NSObject *key in dictionary.allKeys) {
            [array addObject:[NSString stringWithFormat:@"%@=%@", key, [dictionary objectForKey:key]]];
        }
        return [NSArray arrayWithArray:array];
    };
    
    NSString *(^parametersToString)(NSArray *array) = ^(NSArray *array) {
        return [array componentsJoinedByString:@"&"];
    };
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = parameters;
        if (dict.count == 0) {
            return NULL;
        }
        return parametersToString(parametersToArray(parameters));
    }
    else if ([parameters isKindOfClass:[NSArray class]]) {
        NSArray *array = parameters;
        if (array.count == 0) {
            return NULL;
        }
        return parametersToString(parameters);
    }
    else if ([parameters isKindOfClass:[NSString class]]) {
        return parameters;
    }
    else {
        return NULL;
    }
}


@end
