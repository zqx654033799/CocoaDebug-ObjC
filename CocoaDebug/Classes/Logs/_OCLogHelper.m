//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogHelper.h"
#import "_OCLogStoreManager.h"
#import <WebKit/WebKit.h>

void CocoaDebugLog(NSString *format, ...)
{
    va_list lv;
    va_start(lv, format);
    NSLogv(format, lv);
    va_end(lv);
}

@implementation _OCLogHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.enable = YES;
    }
    return self;
}

- (void)userContentController:(id)userContentController didReceiveScriptMessage:(id)message;
{
    WKScriptMessage *sMessage = message;
    NSString *name = [NSString stringWithFormat:@"[WKWebView] %@", sMessage.name];
    NSString *body = [NSString stringWithFormat:@"%@", sMessage.body];
    
    [self handleLogWithFile:name message:body h5LogType:H5LogTypeWK];
    
    CocoaDebugLog(@"%@ %@", name, body);
}

- (void)handleLogWithFile:(NSString *)file message:(NSString *)message h5LogType:(H5LogType)h5LogType;
{
    if (!self.enable) {
        return;
    }
    if (_IsStringEmpty(message)) {
        return;
    }
    message = [message stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (_IsStringEmpty(message)) {
        return;
    }
    if (_IsStringNotEmpty(file)) {
        file = [file stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    _OCLogModel *log = [[_OCLogModel alloc] initWithContent:message fileInfo:file];
    log.h5LogType = h5LogType;
    [_OCLogStoreManager.shared addLog:log];
}

@end
