//
//  RequestHandler.m
//  ESRequest Example
//
//  Created by 翟泉 on 16/4/28.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "RequestHandler.h"

#import "APIConfigManager.h"

@interface RequestHandler ()
{
    AFNetworkReachabilityStatus _networkReachabilityStatus;
}

@property(strong, nonatomic, nonnull) AFHTTPSessionManager *HTTPSessionManager;

@end

@implementation RequestHandler

@synthesize networkReachabilityStatus;

+ (nonnull RequestHandler *)sharedInstance; {
    static RequestHandler * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init; {
    if (self = [super init]) {
        self.HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[APIConfigManager sharedInstance].baseURLString] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [self.HTTPSessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
            return [[RequestHandler sharedInstance] queryStringSerialization:request parameters:parameters error:error];
        }];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            _networkReachabilityStatus = status;
        }];
    }
    return self;
}

- (NSString *)queryStringSerialization:(NSURLRequest *)request parameters:(id)parameters error:(NSError *__autoreleasing *)error; {
    
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
        return parametersToString(parametersToArray(parameters));
    }
    else if ([parameters isKindOfClass:[NSArray class]]) {
        return parametersToString(parameters);
    }
    else if ([parameters isKindOfClass:[NSString class]]) {
        return parameters;
    }
    else {
        return @"";
    }
}

- (AFNetworkReachabilityStatus)networkReachabilityStatus; {
    return _networkReachabilityStatus;
}

@end
