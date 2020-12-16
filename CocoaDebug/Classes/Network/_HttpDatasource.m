//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_HttpDatasource.h"
#import "_NetworkHelper.h"
#import "CocoaDebug+Extensions.h"

NSNotificationName const HttpModelsChangedNotification = @"_HttpModelsChangedNotification";

@implementation _HttpDatasource

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.httpModels = [NSMutableArray arrayWithCapacity:CocoaDebug.logMaxCount];
    }
    return self;
}

- (BOOL)addHttpRequset:(_HttpModel*)model
{
    if ([model.url.absoluteString isEqualToString:@""]) {
        return NO;
    }
    
    
    //url过滤, 忽略大小写
    for (NSString *urlString in [[_NetworkHelper shared] ignoredURLs]) {
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {
            return NO;
        }
    }
    
    BOOL changed = NO;
    //最大个数限制
    if (self.httpModels.count >= CocoaDebug.logMaxCount) {
        if ([self.httpModels count] > 0) {
            [self.httpModels removeObjectAtIndex:0];
            changed = YES;
        }
    }
    
    //判断重复
    __block BOOL isExist = NO;
    [self.httpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.requestId isEqualToString:model.requestId]) {//数组中已经存在该对象
            isExist = YES;
        }
    }];
    if (!isExist) {//如果不存在就添加进去
        [self.httpModels addObject:model];
        changed = YES;
    } else {
        return NO;
    }
    
    if (changed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
        });
    }
    
    return YES;
}

- (void)reset
{
    [self.httpModels removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
    });
}

- (void)remove:(_HttpModel *)model
{
    [self.httpModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.requestId isEqualToString:model.requestId]) {
            [self.httpModels removeObjectAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
            });
            *stop = YES;
        }
    }];
}

@end
