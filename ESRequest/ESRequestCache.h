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

/**
 *  存储数据的硬盘目录路径
 */
@property (strong, nonatomic, readonly) NSString *diskPath;


+ (instancetype)sharedInstance;

/**
 *  存储数据
 *
 *  @param request <#request description#>
 */
- (void)storeCachedJSONObjectForRequest:(ESRequest *)request;
/**
 *  获取缓存数据
 *
 *  @param request   <#request description#>
 *  @param isTimeout <#isTimeout description#>
 *
 *  @return <#return value description#>
 */
- (NSObject *)cachedJSONObjectForRequest:(ESRequest *)request isTimeout:(BOOL *)isTimeout;
/**
 *  移除缓存
 *
 *  @param request <#request description#>
 */
- (void)removeCachedJSONObjectForRequest:(ESRequest *)request;

/**
 *  存储数据
 *
 *  @param cachedData 数据
 *  @param path       路径
 */
- (void)storeCachedData:(NSData *)cachedData ForPath:(NSString *)path;
/**
 *  获取缓存数据
 *
 *  @param path            缓存路径
 *  @param timeoutInterval 缓存超时时间
 *  @param isTimeout       是否超时
 *
 *  @return <#return value description#>
 */
- (NSData *)cachedDataForPath:(NSString *)path TimeoutInterval:(NSTimeInterval)timeoutInterval IsTimeout:(BOOL *)isTimeout;
/**
 *  移除缓存
 *
 *  @param path 缓存路径
 */
- (void)removeCachedDataForPath:(NSString *)path;

/**
 *  移除所有缓存
 */
- (void)removeAllCachedData;

@end

