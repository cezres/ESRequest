//
//  ProductRequest.m
//  ESRequest
//
//  Created by 翟泉 on 2016/7/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ProductRequest.h"

@implementation ProductRequest

- (NSString *)URLString {
    return @"http://app.bilibili.com/x/region/list/old";
}

- (HTTPMethod)method {
    return HTTPMethodGet;
}

- (NSTimeInterval)cacheTimeoutInterval {
    return 60*10;
}

@end
