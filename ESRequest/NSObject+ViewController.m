//
//  NSObject+ViewController.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/13.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "NSObject+ViewController.h"

@implementation NSObject (ViewController)

#pragma mark - 获得控制器
- (id<UIApplicationDelegate>)es_applicationDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (UIViewController *)es_rootViewController; {
    return self.es_applicationDelegate.window.rootViewController;
}

- (UINavigationController*)es_currentNavigationViewController
{
    UIViewController* currentViewController = [self es_currentViewController];
    return currentViewController.navigationController;
}

- (UIViewController *)es_currentViewController
{
    UIViewController* rootViewController = self.es_rootViewController;
    return [self es_currentViewControllerFrom:rootViewController];
}

/**
 *  返回当前的控制器,以viewController为节点开始寻找
 */
- (UIViewController*)es_currentViewControllerFrom:(UIViewController*)viewController
{
    //传入的根节点控制器是导航控制器
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController *)viewController;
        return [self es_currentViewControllerFrom:navigationController.viewControllers.lastObject];
    }
    else if([viewController isKindOfClass:[UITabBarController class]]) //传入的根节点控制器是UITabBarController
    {
        UITabBarController* tabBarController = (UITabBarController *)viewController;
        return [self es_currentViewControllerFrom:tabBarController.selectedViewController];
    }
    else if(viewController.presentedViewController != nil)  //传入的根节点控制器是被展现出来的控制器
    {
        return [self es_currentViewControllerFrom:viewController.presentedViewController];
    }
    else
    {
        return viewController;
    }
}


@end
