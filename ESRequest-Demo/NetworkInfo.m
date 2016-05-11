//
//  NetworkInfo.m
//  HTTPServer Example
//
//  Created by 翟泉 on 16/4/20.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "NetworkInfo.h"
#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NetworkInfo

+ (NSString *)IPAddress; {
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

+ (NSString *)WifiName; {
    NSString *wifiName = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
#pragma clang diagnostic pop
    
    CFRelease(wifiInterfaces);
    return wifiName;
}


+ (NSString *)WiFiIPAddress; {
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

@end