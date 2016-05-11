//
//  HTTPServerDemo.m
//  ESRequest
//
//  Created by 翟泉 on 16/5/7.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "HTTPServerDemo.h"
#import <CocoaHTTPServer/HTTPServer.h>
#import "NetworkInfo.h"

#import <HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPMessage.h>



@implementation HTTPServerDemo

+ (void)start; {
    static HTTPServer *server;
    if (!server) {
        server = [[HTTPServer alloc] init];
        [server setType:@"_http._tcp."];
        [server setConnectionClass:[HTTPServerDemo class]];
    }
    
    [server setPort:22333];
    
    
    NSLog(@"%@", [NetworkInfo IPAddress]);
    NSLog(@"%@", [NetworkInfo WiFiIPAddress]);
    NSLog(@"%@", [NetworkInfo WifiName]);
    
    
    [server setInterface:[NetworkInfo IPAddress]];
    
    NSError *error;
    if (![server start:NULL]) {
        NSLog(@"%@", error);
        return;
    }
    
    

    
    
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path; {
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path; {
    if([method isEqualToString:@"POST"])
        return YES;
    return [super expectsRequestBodyFromMethod:method atPath:path];
}


- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path; {
    
    if ([path isEqualToString:@"/api/page/index/MAIN"]) {
        
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
        [result setObject:@"1" forKey:@"status"];
        [result setObject:@"" forKey:@"msg"];
        
        NSMutableArray *modules = [NSMutableArray arrayWithCapacity:2];
        for (int i=0; i<2; i++) {
            [modules addObject:@{@"title":@"AAAA", @"index":@(i)}];
        }
        [result setObject:modules forKey:@"data"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:NULL];
        
        return [[HTTPDataResponse alloc] initWithData:data];
    }
    else if ([path isEqualToString:@"/member/login"] && [method isEqualToString:@"POST"]) {
        NSData *bodyData = [request body];
        if (!bodyData) {
            return NULL;
        }
        NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", bodyString);
    }
    else if ([path hasPrefix:@"/product/list"]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        NSString *components = [path componentsSeparatedByString:@"?"][1];
        for (NSString *component in [components componentsSeparatedByString:@"&"]) {
            [parameters setObject:[component componentsSeparatedByString:@"="][1] forKey:[component componentsSeparatedByString:@"="][0]];
        }
        
        NSString *p = [parameters objectForKey:@"p"];
        
        if ([p integerValue] <=0 || [p integerValue] > 5) {
            return NULL;
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Products%@", p] ofType:@""];
        if (!path) {
            return NULL;
        }
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if (!data) {
            return NULL;
        }
        sleep(4);
        return [[HTTPDataResponse alloc] initWithData:data];
    }
    else if ([path hasPrefix:@"/product/"]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
        if ([path.lastPathComponent integerValue] == 0) {
            [result setObject:@"-1" forKey:@"status"];
            [result setObject:@"不存在该商品" forKey:@"msg"];
        }
        else {
            [result setObject:@"1" forKey:@"status"];
            [result setObject:@"" forKey:@"msg"];
            [result setObject:@{@"id": path.lastPathComponent,@"name":@"AAAAA", @"price":@10086.11} forKey:@"data"];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:NULL];
        return [[HTTPDataResponse alloc] initWithData:data];
    }
    
    
    return NULL;
}




@end
