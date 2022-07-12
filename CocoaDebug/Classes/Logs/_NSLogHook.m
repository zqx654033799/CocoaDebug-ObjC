//
//  _NSLogHook.m
//  Example_Swift
//
//  Created by man.li on 7/26/19.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "fishhook.h"
#import "_OCLogHelper.h"

@interface _NSLogHook : NSObject
@end

@implementation _NSLogHook

static void (*origNSLog)(NSString *format, ...);

void replNSLog(NSString *format, ...)
{
    va_list vl;
    va_start(vl, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:vl];
    va_end(vl);
    
    [_OCLogHelper.shared handleLogWithFile:@"" message:log h5LogType:H5LogTypeNone];
    
    origNSLog(@"%@", log);
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct rebinding nslog_rebinding = {"NSLog", replNSLog, (void*)&origNSLog};
        rebind_symbols((struct rebinding[1]){nslog_rebinding}, 1);
    });
}

@end
