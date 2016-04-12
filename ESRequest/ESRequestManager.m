//
//  ESRequestManager.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestManager.h"
//#import "ESRequest.h"

@implementation ESRequestManager

+ (nonnull ESRequestManager *)sharedInstance; {
    static ESRequestManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init; {
    if (self = [super init]) {
        self.HTTPSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[ESRequestConfigManager sharedInstance].baseURLString] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        __weak typeof(self) weakself = self;
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakself.status = status;
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    break;
                case AFNetworkReachabilityStatusUnknown:
                    break;
                default:
                    break;
            }
        }];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [self.HTTPSessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.HTTPSessionManager.requestSerializer.timeoutInterval = 8.0f;
        [self.HTTPSessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    return self;
}

- (void)sendRequest:(ESRequest *)request; {
    //    NSCParameterAssert(request.config);
    
    id<ESRequestManagerDelegate> delegate = NULL;
    if ([request conformsToProtocol:@protocol(ESRequestManagerDelegate)]) {
        delegate = (id<ESRequestManagerDelegate>)request;
    }
    
    if (request.config.Method == ESRequestMethodGET) {
        [self HTTPRequestWithMethod:@"GET" URLString:request.config.URLString Parameters:request.config.parameters Delegate:delegate];
    }
    else if (request.config.Method == ESRequestMethodPOST) {
        [self HTTPRequestWithMethod:@"POST" URLString:request.config.URLString Parameters:request.config.parameters Delegate:delegate];
    }
    else if (request.config.Method == ESRequestMethodUpload) {
        [self UploadRequestWithURLString:request.config.URLString Name:request.config.Name FileName:@"57wq1sq" MimeType:request.config.MimeType Data:request.uploadData Delegate:delegate];
    }
    else if (request.config.Method == ESRequestMethodDownload) {
        [self DownloadRequestWithURLString:request.config.URLString StorePath:request.config.downloadStorePath Delegate:delegate];
    }
}

- (void)setAccesstoken:(NSString *)accesstoken; {
    [self.HTTPSessionManager.requestSerializer setValue:accesstoken forHTTPHeaderField:@"accesstoken"];
}



- (void)HTTPRequestWithMethod:(NSString *)method URLString:(NSString *)URLString Parameters:(id)parameters Delegate:(id<ESRequestManagerDelegate>)delegate; {
    
    if ([method isEqualToString:@"GET"]) {
        [self.HTTPSessionManager GET:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            //
            [delegate networkCompleted:self responseObject:responseObject error:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            [delegate networkCompleted:self responseObject:NULL error:error];
        }];
    }
    else if ([method isEqualToString:@"POST"]) {
        [self.HTTPSessionManager POST:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            //
            [delegate networkCompleted:self responseObject:responseObject error:NULL];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
            [delegate networkCompleted:self responseObject:NULL error:error];
        }];
    }
}


- (void)UploadRequestWithURLString:(NSString *)URLString Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Data:(NSData *)data Delegate:(id<ESRequestManagerDelegate>)delegate; {
    NSCParameterAssert(data);
    
     NSMutableURLRequest *requestss = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
     } error:nil];
    
     __autoreleasing NSProgress *progress = nil;
     NSURLSessionUploadTask *uploadTask = [self.HTTPSessionManager uploadTaskWithStreamedRequest:requestss progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
     if (error) {
         NSLog(@"Error: %@", error);
     } else {
         NSLog(@"%@ %@", response, responseObject);
     }
         [delegate networkCompleted:self responseObject:responseObject error:error];
     }];
    
    //    [self.KVOController observe:progress keyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
    //        if ([object isMemberOfClass:[NSProgress class]]) {
    //            NSProgress *_progress = object;
    //            NSLog(@"%lld/%lld", _progress.completedUnitCount, _progress.totalUnitCount);
    //            if ([delegate respondsToSelector:@selector(networkProgress:completedUnitCount:totalUnitCount:)]) {
    //                [delegate networkProgress:self completedUnitCount:_progress.completedUnitCount totalUnitCount:_progress.totalUnitCount];
    //            }
    //        }
    //    }];
    
    [uploadTask resume];
}

- (void)DownloadRequestWithURLString:(NSString *)URLSting StorePath:(NSString *)storePath Delegate:(id<ESRequestManagerDelegate>)delegate; {
    NSURL *URL = [NSURL URLWithString:URLSting];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    __autoreleasing NSProgress *progress = nil;
    NSURLSessionDownloadTask *downloadTask = [self.HTTPSessionManager downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        return url;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //
        NSData *data = [NSData dataWithContentsOfURL:filePath];
        NSLog(@"%s", [data bytes]);
        if ([delegate respondsToSelector:@selector(networkDownloadCompleted:filePath:error:)]) {
            [delegate networkDownloadCompleted:self filePath:filePath error:error];
        }
    }];
    
    //    [self.KVOController observe:progress keyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
    //        if ([object isMemberOfClass:[NSProgress class]]) {
    //            NSProgress *_progress = object;
    //            NSLog(@"%lld/%lld", _progress.completedUnitCount, _progress.totalUnitCount);
    //            if ([delegate respondsToSelector:@selector(networkProgress:completedUnitCount:totalUnitCount:)]) {
    //                [delegate networkProgress:self completedUnitCount:_progress.completedUnitCount totalUnitCount:_progress.totalUnitCount];
    //            }
    //        }
    //    }];
    
    [downloadTask resume];
}

@end
