//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "CocoaDebug+Extensions.h"

NSNotificationName const LogDefaultChangedNotification = @"_LogDefaultChangedNotification";
NSNotificationName const LogColorChangedNotification   = @"_LogColorChangedNotification";
NSNotificationName const LogH5ChangedNotification      = @"_LogH5ChangedNotification";

@interface _OCLogStoreManager ()
{
    dispatch_semaphore_t semaphore;
}
@end

@implementation _OCLogStoreManager

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
        
        self.defaultLogArray = [NSMutableArray arrayWithCapacity:CocoaDebug.logMaxCount];
        self.colorLogArray = [NSMutableArray arrayWithCapacity:CocoaDebug.logMaxCount];
        self.h5LogArray = [NSMutableArray arrayWithCapacity:CocoaDebug.logMaxCount];
    }
    return self;
}

- (void)addLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil)
        {
            //白色
            if ([self.defaultLogArray count] >= CocoaDebug.logMaxCount) {
                if (self.defaultLogArray.count > 0) {
                    [self.defaultLogArray removeObjectAtIndex:0];
                }
            }
            
            [self.defaultLogArray addObject:log];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LogDefaultChangedNotification object:nil];
            });
        }
        else
        {
            //彩色
            if ([self.colorLogArray count] >= CocoaDebug.logMaxCount) {
                if (self.colorLogArray.count > 0) {
                    [self.colorLogArray removeObjectAtIndex:0];
                }
            }
            
            [self.colorLogArray addObject:log];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LogColorChangedNotification object:nil];
            });
        }
    }
    else
    {
        //H5
        if ([self.h5LogArray count] >= CocoaDebug.logMaxCount) {
            if (self.h5LogArray.count > 0) {
                [self.h5LogArray removeObjectAtIndex:0];
            }
        }
        
        [self.h5LogArray addObject:log];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LogH5ChangedNotification object:nil];
        });
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil) {
            //白色
            [self.defaultLogArray removeObject:log];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LogDefaultChangedNotification object:nil];
            });
        } else {
            //彩色
            [self.colorLogArray removeObject:log];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LogColorChangedNotification object:nil];
            });
        }
    }
    else
    {
        //H5
        [self.h5LogArray removeObject:log];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LogH5ChangedNotification object:nil];
        });
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)resetDefaultLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.defaultLogArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LogDefaultChangedNotification object:nil];
    });
    dispatch_semaphore_signal(semaphore);
}

- (void)resetColorLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.colorLogArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LogColorChangedNotification object:nil];
    });
    dispatch_semaphore_signal(semaphore);
}

- (void)resetH5Logs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.h5LogArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LogH5ChangedNotification object:nil];
    });
    dispatch_semaphore_signal(semaphore);
}

@end
