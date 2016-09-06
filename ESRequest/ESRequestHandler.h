//
//  ESRequestHandler.h
//  ESRequest
//
//  Created by 翟泉 on 2016/8/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ESHTTPMethod) {
    ESHTTPMethodGet,
    ESHTTPMethodPost,
};

typedef NS_ENUM(NSInteger, ESNetworkReachabilityStatus) {
    ESNetworkReachabilityStatusUnknown          = -1,
    ESNetworkReachabilityStatusNotReachable     = 0,
    ESNetworkReachabilityStatusReachableViaWWAN = 1,
    ESNetworkReachabilityStatusReachableViaWiFi = 2,
};


@protocol ESRequestHandlerDelegate <NSObject>

/**
 *  请求完成后回调
 *
 *  @param responseObject <#responseObject description#>
 *  @param error          <#error description#>
 */
- (void)requestHandleCompletionResponseObject:(id)responseObject error:(NSError *)error;

@end

@class ESRequest;

@interface ESRequestHandler : NSObject

/**
 *  网络状态
 */
@property (readonly, nonatomic, assign) ESNetworkReachabilityStatus networkReachabilityStatus;
/**
 *  请求超时时间
 */
@property (assign, nonatomic) NSTimeInterval timeoutInterval;

@property (strong, nonatomic) NSString *baseURLString;


+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)handleRequest:(ESRequest *)request;

- (NSURLSessionDataTask *)handleRequestWithURLString:(NSString *)URLString Method:(ESHTTPMethod)method parameters:(id)parameters delegate:(id<ESRequestHandlerDelegate>)delegate;

@end
