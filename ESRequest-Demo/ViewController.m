//
//  ViewController.m
//  ESRequest-Demo
//
//  Created by 翟泉 on 16/5/7.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"

#import "ESRequest.h"
#import "BaseRequest.h"

@interface ViewController ()

@property (strong, nonatomic) BaseRequest *request;

@end


@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Test";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _request = [BaseRequest requestWithLoadingInView:self.view];
    _request.URLString = @"http://open.api.d2cmall.com/v2/api/product/list";
    _request.parameters = @{@"c": @1687, @"t": @1, @"p": @1, @"pageSize": @2};
    [_request startWithCompletionBlock:^(__kindof ESRequest *request) {
        if (request.responseObject) {
            NSLog(@"\n%@", request.responseObject);
        }
        NSLog(@"%@", self);
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_request startNextPageWithCompletionBlock:^(__kindof ESRequest *request) {
            if (request.responseObject) {
                NSLog(@"\n%@", request.responseObject);
            }
            NSLog(@"%@", self);
        }];
    });
    
   
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    BaseRequest *request = [BaseRequest requestWithLoadingInView:self.view];
    request.URLString = @"http://test.api.d2cmall.com/v2/api/page/index/MAIN";
    request.parameters = @{};
    [request startWithCompletionBlock:^(__kindof ESRequest *request) {
        if (request.responseObject) {
            NSLog(@"\n%@", request.responseObject);
        }
    }];
    
}


@end
