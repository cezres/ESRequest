//
//  ViewController.m
//  ESRequest Example
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"

//@import ESRequest;



#import <ESRequest/ESRequest.h>




//#import <ESRequest/ESRequest+NextPage.h>






@interface ViewController ()
<ESRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ESRequestConfigManager sharedInstance].baseURLString = @"http://open.api.d2cmall.com";
    
    NSDictionary<NSNumber*, ESRequestConfig *> *requestConfig;
    requestConfig = @{
               @(RequestTypePageIndex): [ESRequestConfig Config:@"/v2/api/page/index/MAIN" Method:ESRequestMethodGET],
               @(RequestTypePageProductRecommends): [ESRequestConfig Config:@"/v2/api/page/product/recommends" Method:ESRequestMethodGET],
               };
    [[ESRequestConfigManager sharedInstance] setConfigs:requestConfig];
    
    
    
    [[ESRequest RequestWithType:RequestTypePageIndex Parameters:nil Delegate:self] start];
}


#pragma mark - ESRequestDelegate
- (void)requestCompleted:(ESRequest *)request; {
    NSLog(@"\n%@", request.responseObject);
    
    if (request.responseStatusCode != 1) {
        
    }
    else if (request.type == RequestTypePageIndex) {
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
