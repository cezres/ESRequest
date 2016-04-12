//
//  ESRequestConfig.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSInteger, ESRequestMethod) {
    ESRequestMethodGET = 66666,
    ESRequestMethodPOST,
    ESRequestMethodUpload,
    ESRequestMethodDownload
};


@interface ESRequestConfig : NSObject
<NSCopying>

/**
 *  网络请求路径
 */
@property (strong, nonatomic, nonnull) NSString *URLString;
/**
 *  参数
 */
@property (strong, nonatomic, nullable) NSObject *parameters;
/**
 *  网络请求方法
 */
@property (assign, nonatomic) ESRequestMethod Method;
/**
 *  缓存时间  单位 分钟
 */
@property (assign, nonatomic) NSTimeInterval CacheTime;
/**
 *  数据是否可能分页
 */
@property (assign, nonatomic) BOOL Page;
/**
 *  是否需要登录
 */
//@property (assign, nonatomic) BOOL Login;

@property (strong, nonatomic, nullable) NSString *Name;
/**
 *  上传文件类型
 */
@property (strong, nonatomic, nullable) NSString *MimeType;
/**
 *  下载文件存储路径
 */
@property (strong, nonatomic, nullable) NSString *downloadStorePath;

+ (nullable ESRequestConfig *)Config:(nullable NSString *)URLString Method:(ESRequestMethod)method;
+ (nullable ESRequestConfig *)Config:(nullable NSString *)URLString Method:(ESRequestMethod)method CacheTime:(NSTimeInterval)cacheTime Page:(BOOL)page;

- (BOOL)nextPage;

@end
