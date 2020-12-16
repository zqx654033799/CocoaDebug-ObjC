//
//  _CrashStoreManager.h
//  Pods
//
//  Created by iPaperman on 2020/12/15.
//

#import <Foundation/Foundation.h>
#import "_CrashModel.h"

FOUNDATION_EXTERN NSNotificationName const CrashArrayChangedNotification;

@interface _CrashStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<_CrashModel *> *crashArray;

+ (instancetype)shared;

///记录
- (BOOL)addCrash:(_CrashModel*)model;

///清空
- (void)reset;

///删除
- (void)removeCrash:(_CrashModel *)model;

@end
