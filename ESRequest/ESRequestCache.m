//
//  ESRequestCache.m
//  ESRequest
//
//  Created by 翟泉 on 16/4/11.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESRequestCache.h"

@implementation ESRequestCache

- (NSString *)storeCachePath; {
    if (_storeCachePath == nil) {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager changeCurrentDirectoryPath:documentsPath];
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"NetworkCache"] withIntermediateDirectories:YES attributes:nil error:nil];
        _storeCachePath = [documentsPath stringByAppendingString:@"/NetworkCache"];
    }
    return _storeCachePath;
}

- (NSUInteger)cacheSize; {
    __block NSUInteger size = 0;
    [self traverseDirectoryWithPath:self.storeCachePath Block:^(NSString * _Nullable path) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSDictionary *dict = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:true];
#pragma clang diagnostic pop
        size += [[dict valueForKey:NSFileSize] integerValue];
    }];
    return size;
}


+ (nonnull ESRequestCache *)sharedInstance; {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)storeCachedObject:(id)object Token:(NSString *)token Group:(NSString *)group; {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    if (data) {
        NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", self.storeCachePath, group];
        BOOL flag;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager changeCurrentDirectoryPath:self.storeCachePath];
        if (![fileManager fileExistsAtPath:directoryPath isDirectory:&flag] || !flag) {
            [fileManager createDirectoryAtPath:group withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [data writeToFile:[self getFilePathForToken:token Group:group] atomically:YES];
    }
}

- (id)cacheObjectForToken:(NSString *)token Group:(NSString *)group TimeoutInterval:(NSTimeInterval)timeoutInterval; {
    NSData *data = [NSData dataWithContentsOfFile:[self getFilePathForToken:token Group:group]];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}

- (void)cacheObjectForToken:(NSString *)token Group:(NSString *)group TimeoutInterval:(NSTimeInterval)timeoutInterval Completed:(void (^)(id _Nullable, BOOL))completed; {
    NSString *filePath = [self getFilePathForToken:token Group:group];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:filePath traverseLink:true];
#pragma clang diagnostic pop
        NSDate *fileModificationDate = [fileAttributes valueForKey:NSFileModificationDate];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:fileModificationDate];
        completed([NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil], (timeInterval < timeoutInterval));
    }
    completed(NULL, NO);
}

- (void)cacheObjectForToken:(NSString *)token Group:(NSString *)group TimeoutInterval:(NSTimeInterval)timeoutInterval object:(NSObject *__autoreleasing  _Nullable *)object flag:(BOOL *)flag; {
    NSString *filePath = [self getFilePathForToken:token Group:group];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:filePath traverseLink:true];
#pragma clang diagnostic pop
        NSDate *fileModificationDate = [fileAttributes valueForKey:NSFileModificationDate];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:fileModificationDate];
        *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        *flag = (timeInterval > timeoutInterval * 60);
    }
    else {
        *flag = YES;
    }
}

- (void)removeCacheObjectForToken:(NSString *)token Group:(NSString *)group; {
    [[NSFileManager defaultManager] removeItemAtPath:[self getFilePathForToken:token Group:group] error:nil];
}

- (void)removeCacheObjectForGroup:(NSString *)group; {
    [self traverseDirectoryWithPath:[NSString stringWithFormat:@"%@/%@", self.storeCachePath, group] Block:^(NSString * _Nullable path) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }];
}

- (void)removeCacheObjectForPath:(NSString *)path; {
    BOOL flag;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&flag];
    if (flag) {
        
    }
}

- (void)removeAllCache; {
    [self traverseDirectoryWithPath:self.storeCachePath Block:^(NSString * _Nullable path) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }];
}

#pragma mark - Tool

- (NSString *)getFilePathForToken:(NSString *)token Group:(NSString *)group; {
    if (group) {
        return [NSString stringWithFormat:@"%@/%@/%@", self.storeCachePath, group, token];
    }
    return [NSString stringWithFormat:@"%@/%@", self.storeCachePath, token];
}

- (void)traverseDirectoryWithPath:(NSString *)path Block:(void (^)(NSString *path))block; {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    if ([files count] > 0) {
        for (NSString *name in files) {
            NSString *namePath = [NSString stringWithFormat:@"%@/%@", path, name];
            BOOL flag = YES;
            [fileManager fileExistsAtPath:namePath isDirectory:&flag];
            if (flag) {
                [self traverseDirectoryWithPath:namePath Block:block];
            }
            else {
                block(namePath);
            }
        }
    }
    else {
        block(path);
    }
}

@end
