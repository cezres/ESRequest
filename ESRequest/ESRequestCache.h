//
//  ESRequestCache.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESRequestCache : NSObject

/**
 *  缓存在硬盘的主目录
 */
@property (strong, nonatomic, nonnull) NSString *storeCachePath;
/**
 *  当前硬盘缓存的字节
 */
@property(assign, nonatomic, readonly) NSUInteger cacheSize;


/**
 *  @return 返回ESNetWorkCache单例对象
 */
+ (nonnull ESRequestCache *)sharedInstance;

/**
 *  存储缓存数据
 *
 *  @param object 缓存数据
 *  @param token  唯一标识
 *  @param group  组
 */
- (void)storeCachedObject:(nonnull id)object Token:(nonnull NSString *)token Group:(nullable NSString *)group;

/**
 *  获取缓存数据
 *
 *  @param token           唯一标识
 *  @param group           组
 *  @param timeoutInterval 超时时间  单位 分
 *  @param object          缓存对象
 *  @param flag            是否超时
 */
- (void)cacheObjectForToken:(nonnull NSString *)token Group:(nullable NSString *)group TimeoutInterval:(NSTimeInterval)timeoutInterval object:( NSObject * _Nullable  __autoreleasing * _Nonnull)object flag:(BOOL * _Nonnull)flag;

/**
 *  清除缓存数据
 *
 *  @param token 唯一标识
 *  @param group 组
 */
- (void)removeCacheObjectForToken:(nonnull NSString *)token Group:(nullable NSString *)group;

/**
 *  清除一组缓存数据
 *
 *  @param group 组
 */
- (void)removeCacheObjectForGroup:(nonnull NSString *)group;

/**
 *  清除全部缓存
 */
- (void)removeAllCache;

/**
 *  遍历目录
 *
 *  @param path  目录路径
 *  @param block 文件路径回调
 */
- (void)traverseDirectoryWithPath:(nonnull NSString *)path Block:(void (^ _Nullable)(NSString * _Nullable path))block;

@end
