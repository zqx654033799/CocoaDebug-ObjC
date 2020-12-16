//
//  CrashHelper.h
//  Pods
//
//  Created by iPaperman on 2020/12/15.
//

#import <Foundation/Foundation.h>

@interface _CrashHelper : NSObject

@property (nonatomic, assign) BOOL enable;

+ (instancetype)shared;

@end
