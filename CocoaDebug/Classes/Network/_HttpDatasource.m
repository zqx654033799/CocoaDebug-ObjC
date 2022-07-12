//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_HttpDatasource.h"
#import "_NetworkHelper.h"

NSNotificationName const HttpModelsChangedNotification = @"_HttpModelsChangedNotification";

@interface _HttpDatasource ()
{
    NSMutableDictionary<NSString *, id> *_cacheHttpModelsMap;

    dispatch_semaphore_t semaphore;
}
@end

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
        semaphore = dispatch_semaphore_create(1);

        _cacheHttpModelsMap = [NSMutableDictionary dictionaryWithCapacity:_logMaxCount];
        self.httpModels = [NSMutableArray arrayWithCapacity:_logMaxCount];
    }
    return self;
}

- (_HttpModel *)cacheHttpModelForTask:(NSURLSessionTask *)task;
{
    return [_cacheHttpModelsMap valueForKey:task.cocoadebugUID];
}

- (void)cacheHttpModel:(_HttpModel *)model forTask:(NSURLSessionTask *)task;
{
    [_cacheHttpModelsMap setValue:model forKey:task.cocoadebugUID];
}

- (BOOL)addHttpRequset:(_HttpModel*)model
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (!model.url || [model.url.absoluteString isEqualToString:@""]) {
        dispatch_semaphore_signal(semaphore);

        return NO;
    }
    
    //url过滤, 忽略大小写
    for (NSString *urlString in [[_NetworkHelper shared] ignoredURLs]) {
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {    dispatch_semaphore_signal(semaphore);

            return NO;
        }
    }
    
    BOOL changed = NO;
    //最大个数限制
    if (self.httpModels.count >= _logMaxCount) {
        if ([self.httpModels count] > 0) {
            [self.httpModels removeObjectAtIndex:0];
            changed = YES;
        }
    }
    
    //判断重复
    __block BOOL isExist = NO;
    [self.httpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.taskID isEqualToString:model.taskID]) {//数组中已经存在该对象
            isExist = YES;
        }
    }];
    if (!isExist) {//如果不存在就添加进去
        [self.httpModels addObject:model];
        changed = YES;
    } else {
        dispatch_semaphore_signal(semaphore);

        return NO;
    }
    
    if (changed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
        });
    }
    dispatch_semaphore_signal(semaphore);

    return YES;
}

- (void)reset
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    [_cacheHttpModelsMap removeAllObjects];
    [self.httpModels removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
    });
    
    dispatch_semaphore_signal(semaphore);
}

- (void)remove:(_HttpModel *)model
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    [self.httpModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.taskID isEqualToString:model.taskID]) {
            [self.httpModels removeObjectAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:HttpModelsChangedNotification object:nil];
            });
            *stop = YES;
        }
    }];

    dispatch_semaphore_signal(semaphore);
}

@end
