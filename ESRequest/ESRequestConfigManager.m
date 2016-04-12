//
//  ESRequestConfigManager.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestConfigManager.h"

@implementation ESRequestConfigManager

+ (nonnull ESRequestConfigManager *)sharedInstance; {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init; {
    if (self = [super init]) {
        _requestConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setConfigs:(NSDictionary<NSNumber *,ESRequestConfig *> * _Nonnull)requestConfigs; {
    for (NSNumber *key in requestConfigs.allKeys) {
        ESRequestConfig *value = [requestConfigs objectForKey:key];
        [_requestConfigs setObject:value forKey:key];
    }
}

- (ESRequestConfig *)requestConfigForType:(NSNumber *)type; {
    return [[_requestConfigs objectForKey:type] copy];
}


- (NSString *)baseURLString; {
    if (!_baseURLString) {
        _baseURLString = @"";
    }
    return _baseURLString;
}


@end
