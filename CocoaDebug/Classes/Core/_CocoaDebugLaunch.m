//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaDebug.h"

@interface NSObject (_CocoaDebugLaunch)
@end

@implementation NSObject (_CocoaDebugLaunch)

#pragma mark - load
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cocoadebug_swizzlingForInstance(UIApplication.class, @selector(setDelegate:), @selector(cocoadebug_setDelegate:));
    });
}

- (void)cocoadebug_setDelegate:(id<UIApplicationDelegate>)delegate {
    cocoadebug_swizzlingForInstance(delegate.class, @selector(application:didFinishLaunchingWithOptions:), @selector(cocoadebug_application:didFinishLaunchingWithOptions:));
    
    [self cocoadebug_setDelegate:delegate];
}

- (BOOL)cocoadebug_application:(UIApplication *)app didFinishLaunchingWithOptions:(id)options {
    [CocoaDebug enable];
    return [self cocoadebug_application:app didFinishLaunchingWithOptions:options];
}
@end
