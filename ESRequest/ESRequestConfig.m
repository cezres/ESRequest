//
//  ESRequestConfig.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestConfig.h"

@implementation ESRequestConfig

- (id)copyWithZone:(NSZone *)zone {
    
    ESRequestConfig *model  = [[ESRequestConfig allocWithZone:zone] init];
    model.URLString         = [self.URLString copy];
    model.parameters        = [self.parameters copy];
    model.Method            = self.Method;
    model.CacheTime         = self.CacheTime;
    model.Page              = self.Page;
    model.Name              = [self.Name copy];
    model.MimeType          = [self.MimeType copy];
    model.downloadStorePath = [self.downloadStorePath copy];
    return model;
}

+ (ESRequestConfig *)Config:(NSString *)URLString Method:(ESRequestMethod)method; {
    
    ESRequestConfig *model = [[ESRequestConfig alloc] init];
    model.URLString        = [URLString copy];
    model.Method           = method;
    return model;
}

+ (ESRequestConfig *)Config:(NSString *)URLString Method:(ESRequestMethod)method CacheTime:(NSTimeInterval)cacheTime Page:(BOOL)page; {
    
    ESRequestConfig *model = [[ESRequestConfig alloc] init];
    model.URLString        = [URLString copy];
    model.Method           = method;
    model.CacheTime        = cacheTime;
    model.Page             = page;
    return model;
}


/**
 *  处理网络请求链接中的ID
 *
 *  @param parameters <#parameters description#>
 */
- (void)setParameters:(NSObject *)parameters; {
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
        NSString *Id = [dict objectForKey:@"id"];
        if (![Id isKindOfClass:[NSString class]]) {
            Id = [(NSNumber *)Id stringValue];
        }
        if (NULL != Id) {
            if ([_URLString rangeOfString:@"##"].length > 0) {
                _URLString = [_URLString stringByReplacingOccurrencesOfString:@"##" withString:Id];
                [dict removeObjectForKey:@"id"];
                if ([dict count] == 0) {
                    _parameters = NULL;
                    return;
                }
            }
        }
        _parameters = [NSDictionary dictionaryWithDictionary:dict];
    }
    else {
        _parameters = [parameters copy];;
    }
}


- (BOOL)nextPage; {
    if (self.parameters == NULL) {
        return NO;
    }
    NSInteger p = [[self.parameters valueForKey:@"p"] integerValue];
    if (p >= 0) {
        NSDictionary *dict = (NSDictionary *)_parameters;
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mutableDict setObject:@(p + 1) forKey:@"p"];
        _parameters = [NSDictionary dictionaryWithDictionary:mutableDict];
        return YES;
    }
    else {
        return NO;
    }
}


@end
