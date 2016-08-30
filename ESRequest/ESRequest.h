//
//  ESRequest.h
//  ESRequest
//
//  Created by 翟泉 on 2016/7/19.
//  Copyright © 2016年 云之彼端. All rights reserved.
//


#import "ESRequestHandler.h"

@class ESRequest;

@protocol RequestDelegate <NSObject>

@optional

- (void)requestCompletion:(__kindof ESRequest *)request;

@end


typedef void (^ESRequestCompletionBlock)(__kindof ESRequest *request);


@interface ESRequest : NSObject
<ESRequestHandlerDelegate>


@property (copy, nonatomic) NSString *URLString;

@property (assign, nonatomic) ESHTTPMethod method;

@property (copy, nonatomic) NSObject *parameters;

@property (assign, nonatomic) BOOL mustFromNetwork;

@property (assign, nonatomic) NSTimeInterval cacheTimeoutInterval;



@property (copy, nonatomic, readonly) NSString *groupName;

@property (copy, nonatomic, readonly) NSString *identifier;


@property (readonly) NSURLSessionTaskState state;

@property (strong, nonatomic, readonly) id responseObject;

@property (strong, nonatomic, readonly) NSError *error;


@property (assign, nonatomic) NSInteger tag;


@property (weak, nonatomic) id<RequestDelegate> delegate;
/**
 *  请求完成后会释放
 */
@property (copy, nonatomic) ESRequestCompletionBlock completionBlock;


+ (instancetype)request;


- (__kindof ESRequest *)startWithDelegate:(id<RequestDelegate>)delegate;

- (__kindof ESRequest *)startWithCompletionBlock:(ESRequestCompletionBlock)completionBlock;

- (__kindof ESRequest *)start;

- (__kindof ESRequest *)pause;

- (__kindof ESRequest *)stop;



- (void)willStart;

- (void)completed __attribute__((objc_requires_super));

/*
- (void)willStart __attribute__((objc_requires_super));

- (void)willReadCache __attribute__((objc_requires_super));

- (BOOL)didReadCache;

- (void)completed __attribute__((objc_requires_super));

- (void)success __attribute__((objc_requires_super));

- (void)failure __attribute__((objc_requires_super));

- (BOOL)willStoreCache;
*/

@end
