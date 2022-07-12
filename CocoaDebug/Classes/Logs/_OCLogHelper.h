//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_OCLogModel.h"
#import <WebKit/WebKit.h>

FOUNDATION_EXPORT void CocoaDebugLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

@interface _OCLogHelper : NSObject<WKScriptMessageHandler>

@property (nonatomic, assign) BOOL enable;

+ (instancetype)shared;

- (void)handleLogWithFile:(NSString *)file message:(NSString *)message h5LogType:(H5LogType)h5LogType;

@end
