//
//  ViewController.m
//  ESRequest-Demo
//
//  Created by 翟泉 on 16/5/7.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import <HTTPServer.h>
#import "HTTPServerDemo.h"
#import "NetworkInfo.h"



#import "ESRequest.h"

#import "ProductRequest.h"



@interface ViewController ()
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
    [server setInterface:[NetworkInfo WiFiIPAddress]];
    
    NSError *error;
    if (![server start:&error]) {
        NSLog(@"%@", error);
        return;
    }
    
    [RequestHandler sharedInstance].baseURLString = [NSString stringWithFormat:@"http://%@:22333", [NetworkInfo WiFiIPAddress]];
    
    
    
    
//    [[ProductRequest requestWithCompletionBlock:^(Request *request) {
//        if (request.responseObject) {
////            NSLog(@"%@", request.responseObject);
//        }
//    }] resume];
    
    
    Request *request = [Request requestWithCompletionBlock:^(Request *request) {
        if (request.responseObject) {
            NSLog(@"%@", request.responseObject);
        }
    }];
    request.URLString = @"/product/%%id%%";
    request.parameters = @{@"id": @3727026};
    request.method = HTTPMethodGet;
    request.cacheTimeoutInterval = 60*10;
    [request resume];
    
    
    
    
    
}


@end
