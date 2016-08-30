//
//  ESRequestCache.h
//  ESRequest
//
//  Created by 翟泉 on 2016/8/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRequest.h"

@interface ESRequestCache : NSObject

@property (strong, nonatomic) NSString *diskPath;

+ (instancetype)sharedInstance;


- (void)storeCachedJSONObjectForRequest:(ESRequest *)request;

- (NSObject *)cachedJSONObjectForRequest:(ESRequest *)request isTimeout:(BOOL *)isTimeout;

- (void)removeCachedJSONObjectForRequest:(ESRequest *)request;


- (void)storeCachedData:(NSData *)cachedData ForPath:(NSString *)path;

- (NSData *)cachedDataForPath:(NSString *)path TimeoutInterval:(NSTimeInterval)timeoutInterval IsTimeout:(BOOL *)isTimeout;

- (void)removeCachedDataForPath:(NSString *)path;


- (void)removeAllCachedData;

@end

