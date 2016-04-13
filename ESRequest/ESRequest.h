//
//  ESRequest.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/12.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRequestCache.h"
#import "ESRequestConfig.h"
#import "ESRequestConfigManager.h"
#import <MBProgressHUD/MBProgressHUD.h>



@class ESRequest;


/**
 *  ESRequest代理协议
 */
@protocol ESRequestDelegate <NSObject>

@optional
/**
 *  请求完成后回调
 *
 *  @param request 请求对象
 */
- (void)requestCompleted:(ESRequest * _Nonnull)request;
/**
 *  上传/下载文件进度回调
 *
 *  @param request            请求对象
 *  @param completedUnitCount <#completedUnitCount description#>
 *  @param totalUnitCount     <#totalUnitCount description#>
 */
- (void)requestProgress:(nonnull ESRequest *)request completedUnitCount:(int64_t)completedUnitCount totalUnitCount:(int64_t)totalUnitCount;
/**
 *  下载文件结束后回调
 *
 *  @param request  <#request description#>
 *  @param filePath <#filePath description#>
 *  @param error    <#error description#>
 */
- (void)requestDownloadCompleted:(nonnull ESRequest *)request filePath:(NSURL * _Nullable)filePath error:(NSError * _Nullable)error;

@end



@interface ESRequest : NSObject

#pragma mark - 参数
/**
 *  请求类型
 */
@property(assign, nonatomic) NSInteger type;
/**
 *  请求配置
 */
@property (strong, nonatomic, nonnull) ESRequestConfig *config;
/**
 *  上传的数据
 */
@property (strong, nonatomic, nullable) NSData *uploadData;
/**
 *  标记
 */
@property (assign, nonatomic) NSInteger tag;
/**
 *  是否正在执行
 */
@property (assign, nonatomic, getter=isEexecuting, readonly) BOOL executing;
/**
 *  请求唯一标识
 */
@property (strong, nonatomic, readonly, nonnull) NSString *MD5;
/**
 *  是否必须从网络中获取数据  默认NO
 */
@property (assign, nonatomic, getter=isDataFromNetwork) BOOL dataFromNetwork;



#pragma mark - 回调
@property (weak, nonatomic, nullable) id<ESRequestDelegate> delegate;
@property (copy, nonatomic, nullable) void (^successCompletionBlock)(ESRequest * _Nonnull request);
@property (copy, nonatomic, nullable) void (^failureCompletionBlock)(ESRequest * _Nonnull request);
@property (copy, nonatomic, nullable) void (^completionBlock)(ESRequest * _Nonnull request);

#pragma mark - 返回数据
@property (strong, nonatomic, nullable) id responseObject;
@property (strong, nonatomic, readonly, nullable) NSError *error;

@property (nonatomic, assign, readonly) NSInteger responseStatusCode;
@property (strong, nonatomic, readonly, nonnull) NSString *responseMsg;
@property (strong, nonatomic, readonly, nullable) NSDictionary *responseData;

#pragma mark - 初始化
//- (instancetype)initWithType:(NSInteger)type;
+ (nonnull ESRequest *)RequestWithType:(NSInteger)type Parameters:(nullable id)parameters Delegate:(nullable id<ESRequestDelegate>)delegate;
+ (nonnull ESRequest *)RequestWithType:(NSInteger)type Parameters:(nullable id)parameters completionBlock:(nullable void (^)(ESRequest * _Nonnull request))completionBlock;

/**
 *  带加载提示框的网络请求
 *
 *  @param type       <#type description#>
 *  @param parameters <#parameters description#>
 *  @param delegate   <#delegate description#>
 *
 *  @return <#return value description#>
 */
+ (nonnull ESRequest *)RequestHUDWithType:(NSInteger)type Parameters:(nullable id)parameters Delegate:(nullable id<ESRequestDelegate>)delegate;
+ (nonnull ESRequest *)RequestHUDWithType:(NSInteger)type Parameters:(nullable id)parameters completionBlock:(nullable void (^)(ESRequest * _Nonnull request))completionBlock;

/**
 *  必须从网络中加载数据   数据刷新
 *
 *  @param type       <#type description#>
 *  @param parameters <#parameters description#>
 *  @param delegate   <#delegate description#>
 *
 *  @return <#return value description#>
 */
+ (nonnull ESRequest *)RequestHUDFromNetworkWithType:(NSInteger)type Parameters:(nullable id)parameters Delegate:(nullable id<ESRequestDelegate>)delegate;






#pragma mark - 执行

/**
 *  发送网络请求
 */
- (void)start;

/**
 *  停止
 */
- (void)stop;


#pragma mark - 加载下一页数据
@property (assign, nonatomic, readonly) NSInteger index;
@property (assign, nonatomic, readonly) BOOL next;
@property (strong, nonatomic, nullable, readonly) NSArray<__kindof NSString *> *nextKeyPath;
/**
 *  加载下一页数据
 *
 *  @return 是否成功发送网络请求
 */
- (BOOL)nextPage;

#pragma mark - 缓存

/**
 *  清理缓存
 *
 *  @param type 网络请求类型
 */
+ (void)removeCahceWithType:(NSInteger)type;

#pragma mark - 提示框
/**
 *  隐藏提示框  默认YES
 */
@property (assign, nonatomic, getter=isHiddenHUD) BOOL hiddenHUD;
/**
 *  提示框
 */
@property (strong, nonatomic, nullable) MBProgressHUD *HUD;
/**
 *  提示框的父视图
 */
@property (weak, nonatomic, nullable) UIView *hudSuperView;

@end