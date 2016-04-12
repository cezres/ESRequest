//
//  ESRequestConfigManager.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRequestConfig.h"

@interface ESRequestConfigManager : NSObject


/**
 *  网络请求服务器地址
 */
@property(strong, nonatomic, nonnull) NSString *baseURLString;


@property(strong, nonatomic, nonnull) NSMutableDictionary<NSNumber*, ESRequestConfig *> *requestConfigs;

/**
 *  @return 返回ESNetWorkCache单例对象
 */
+ (nonnull ESRequestConfigManager *)sharedInstance;

- (ESRequestConfig * _Nullable)requestConfigForType:(nonnull NSNumber *)type;

- (void)setConfigs:(NSDictionary<NSNumber *,ESRequestConfig *> * _Nonnull)requestConfigs;

@end
