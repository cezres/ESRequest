//
//  ViewController.m
//  ESRequest-Demo
//
//  Created by 翟泉 on 16/5/7.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import <ESRequest/ESRequest.h>
#import <HTTPServer.h>
#import "HTTPServerDemo.h"
#import "NetworkInfo.h"

// ESRequest Test
#import "ProductInfoRequest.h"

typedef NS_ENUM(APIType, APIType__) {
    APITypeHomeModuleIndex = 100,
    APITypeHomeModuleContent,
    
    APITypeMemberLogin = 200,
    
    APITypeProductList = 300,
};



@interface ViewController ()
<ESRequestDelegate>
{
    HTTPServer *server;
    UIActivityIndicatorView *activityIndicatorView;
}
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Test";
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    
    server = [[HTTPServer alloc] init];
    [server setType:@"_http._tcp."];
    [server setConnectionClass:[HTTPServerDemo class]];
    
    [server setPort:22333];
    [server setInterface:[NetworkInfo IPAddress]];
    
    
    NSLog(@"%@", [NetworkInfo IPAddress]);
    
    
    NSError *error;
    if (![server start:&error]) {
        NSLog(@"%@", error);
        return;
    }
    
    
    
    
    [ESAPIConfigManager sharedInstance].baseURLString = [NSString stringWithFormat:@"http://%@:22333", [NetworkInfo IPAddress]];
    
    
    [[ESAPIConfigManager sharedInstance] addAPIType:APITypeHomeModuleIndex withURLString:@"/api/page/index/MAIN" Method:HTTPMethodGet CacheTimeoutInterval:120];
    
    [[ESAPIConfigManager sharedInstance] addAPIType:APITypeHomeModuleContent withURLString:@"/api/page/module/%%id%%" Method:HTTPMethodGet];
    
    [[ESAPIConfigManager sharedInstance] addAPIType:APITypeMemberLogin withURLString:@"/member/login" Method:HTTPMethodPost];
    
    [[ESAPIConfigManager sharedInstance] addAPIType:APITypeProductList withURLString:@"product/list" Method:HTTPMethodGet];
    
    
//    [[ESRequest RequestWithAPIType:APITypeHomeModuleIndex parameters:NULL delegate:self] start];
    
//    [[ESRequest RequestWithAPIType:APITypeHomeModuleContent parameters:@{@"id":@40} delegate:self] start];
    
//    [[[ProductInfoRequest alloc] initWithProductId:159] start];
    
    [[ESRequest RequestWithAPIType:APITypeProductList parameters:@{@"p": @1} delegate:self] start];
    
    
    
}



#pragma mark - ESRequestDelegate

- (void)willStartRequest:(ESRequest *)request; {
    self.navigationItem.titleView = activityIndicatorView;
    [activityIndicatorView startAnimating];
}

- (void)requestCompletion:(ESRequest *)request;
{
    [activityIndicatorView stopAnimating];
    
    if (request.error) {
        NSLog(@"%@", [request.error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return;
    }
    
    NSLog(@"%@", request.responseObject);
    
    
    if (request.type == APITypeProductList) {
        
        if (request.next) {
            if (request.index == 5) {
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [request nextPage];
            });
            
        }
        
    }
}


@end
