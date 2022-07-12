//
//  _CrashStoreManager.m
//  Pods
//
//  Created by iPaperman on 2020/12/15.
//

#import "_CrashStoreManager.h"

NSNotificationName const CrashArrayChangedNotification = @"_CrashArrayChangedNotification";

@implementation _CrashStoreManager

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
        self.crashArray = [NSMutableArray arrayWithCapacity:_logMaxCount];
        NSArray *cacheArray = CocoaDebugSettings.shared.crashList;
        if (cacheArray) {
            [self.crashArray addObjectsFromArray:cacheArray];
        }
    }
    return self;
}

- (BOOL)addCrash:(_CrashModel *)model
{
    BOOL changed = NO;
    //最大个数限制
    if (self.crashArray.count >= _logMaxCount) {
        if ([self.crashArray count] > 0) {
            [self.crashArray removeObjectAtIndex:0];
            changed = YES;
        }
    }
    
    [self.crashArray addObject:model];
    CocoaDebugSettings.shared.crashList = self.crashArray.copy;
    CocoaDebugSettings.shared.crashCount = self.crashArray.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CrashArrayChangedNotification object:nil];
    });
    return YES;
}

- (void)reset
{
    [self.crashArray removeAllObjects];
    CocoaDebugSettings.shared.crashList = self.crashArray.copy;
    CocoaDebugSettings.shared.crashCount = self.crashArray.count;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CrashArrayChangedNotification object:nil];
    });
}

- (void)removeCrash:(_CrashModel *)model
{
    [self.crashArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_CrashModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.mId isEqualToString:model.mId]) {
            [self.crashArray removeObjectAtIndex:index];
            CocoaDebugSettings.shared.crashList = self.crashArray.copy;
            CocoaDebugSettings.shared.crashCount = self.crashArray.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CrashArrayChangedNotification object:nil];
            });
            *stop = YES;
        }
    }];
}
@end
