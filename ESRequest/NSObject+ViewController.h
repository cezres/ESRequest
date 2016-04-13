//
//  NSObject+ViewController.h
//  ESRequest
//
//  Created by 翟泉 on 16/4/13.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (ViewController)

#pragma mark - 获得控制器
/**
 *  根控制器
 *
 *  @return <#return value description#>
 */
- (UIViewController *)es_rootViewController;
/**
 *  当前导航控制器
 *
 *  @return <#return value description#>
 */
- (UINavigationController*)es_currentNavigationViewController;
/**
 *  当前控制器
 *
 *  @return <#return value description#>
 */
- (UIViewController *)es_currentViewController;

@end
