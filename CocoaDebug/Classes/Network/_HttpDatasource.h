//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_HttpModel.h"

FOUNDATION_EXTERN NSNotificationName const HttpModelsChangedNotification;

@interface _HttpDatasource : NSObject

- (_HttpModel *)cacheHttpModelForTask:(NSURLSessionTask *)task;
- (void)cacheHttpModel:(_HttpModel *)model forTask:(NSURLSessionTask *)task;

@property (nonatomic, strong) NSMutableArray<_HttpModel *> *httpModels;

+ (instancetype)shared;

///记录
- (BOOL)addHttpRequset:(_HttpModel*)model;

///清空
- (void)reset;

///删除
- (void)remove:(_HttpModel *)model;

@end
