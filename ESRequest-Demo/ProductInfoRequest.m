//
//  ProductInfoRequest.m
//  ESRequest
//
//  Created by 翟泉 on 16/5/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ProductInfoRequest.h"

@interface ProductInfoRequest ()
{
    NSInteger productId;
}
@end

@implementation ProductInfoRequest

- (instancetype)initWithProductId:(NSInteger)productId; {
    if (self = [super init]) {
        
    }
    return self;
}

- (APIType)type; {
    return 0;
}

- (NSString *)URLString; {
    return @"/product/%%id%%";
}

- (HTTPMethod)method; {
    return HTTPMethodGet;
}

- (NSObject *)parameters; {
    return @{@"id": @(productId)};
}

- (void)successCompletion; {
    NSLog(@"%@", self.responseObject);
}

- (void)failureCompletion; {
    NSLog(@"%@", self.error);
}

@end
