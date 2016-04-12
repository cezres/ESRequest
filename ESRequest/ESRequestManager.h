//
//  ESRequestManager.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFHTTPSessionManager.h"
#import "ESRequest.h"
#import <AFNetworking.h>


@class ESRequestManager;


@protocol ESRequestManagerDelegate <NSObject>

@optional

/**
 *  下载/上传进度回调
 */
- (void)networkProgress:(nonnull ESRequestManager *)manager completedUnitCount:(int64_t)completedUnitCount totalUnitCount:(int64_t)totalUnitCount;

/**
 *  网络请求完成后回调
 */
- (void)networkCompleted:(nonnull ESRequestManager *)manager responseObject:(nullable id)responseObject error:(nullable NSError *)error;

/**
 *  下载完成后回调
 */
- (void)networkDownloadCompleted:(nonnull ESRequestManager *)manager filePath:(NSURL * _Nullable)filePath error:(NSError * _Nullable)error;


@end




@interface ESRequestManager : NSObject

@property(strong, nonatomic, nonnull) AFHTTPSessionManager *HTTPSessionManager;

/**
 *  网络状态
 */
@property (assign, nonatomic) AFNetworkReachabilityStatus status;

/**
 *  @return 返回ESNetWorkManager单例对象
 */
+ (nonnull ESRequestManager *)sharedInstance;


- (void)sendRequest:(nonnull ESRequest *)request;





/**
 *  设置请求头
 *
 *  @param value Value
 *  @param field Key
 */
- (void)setAccesstoken:(nonnull NSString *)accesstoken;

/**
 *  发送HTTP请求
 *
 *  @param method     请求类型
 *  @param URLString  地址
 *  @param parameters 参数
 *  @param delegate   代理对象
 */
- (void)HTTPRequestWithMethod:(nonnull NSString *)method
                    URLString:(nonnull NSString *)URLString
                   Parameters:(nullable id)parameters
                     Delegate:(nullable id<ESRequestManagerDelegate>)delegate;

/**
 *  上传文件请求
 *
 *  @param URLString    地址
 *  @param formDataName 字段名称
 *  @param fileName     文件名称
 *  @param mimeType     文件类型
 *  @param data         数据
 *  @param delegate     代理对象
 */
- (void)UploadRequestWithURLString:(nonnull NSString *)URLString
                              Name:(nonnull NSString *)name
                          FileName:(nonnull NSString *)fileName
                          MimeType:(nonnull NSString *)mimeType
                              Data:(nonnull NSData *)data
                          Delegate:(nullable id<ESRequestManagerDelegate>)delegate;

/**
 *  下载文件请求
 *
 *  @param URLSting  地址
 *  @param storePath 存储路径
 *  @param delegate  代理对象
 */
- (void)DownloadRequestWithURLString:(nonnull NSString *)URLSting
                           StorePath:(nonnull NSString *)storePath
                            Delegate:(nullable id<ESRequestManagerDelegate>)delegate;

@end
