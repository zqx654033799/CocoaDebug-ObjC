//
//  WKWebView+Swizzling.m
//  1233213
//
//  Created by man.li on 2019/1/8.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "_OCLogHelper.h"

@implementation WKWebView (_Swizzling)

#pragma mark - life
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL original_sel = @selector(initWithFrame:configuration:);
        SEL replaced_sel = @selector(_cocoadebug_initWithFrame:configuration:);
        cocoadebug_swizzlingForInstance(WKWebView.class, original_sel, replaced_sel);
    });
}

#pragma mark - replaced method
- (instancetype)_cocoadebug_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (!configuration) {
        configuration = [[WKWebViewConfiguration alloc] init];
    }
    
    [self log:configuration];
    [self error:configuration];
    [self warn:configuration];
    [self debug:configuration];
    [self info:configuration];
    
    return [self _cocoadebug_initWithFrame:frame configuration:configuration];
}

#pragma mark - private
- (void)log:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"log"];
    [configuration.userContentController addScriptMessageHandler:_OCLogHelper.shared name:@"log"];
    //rewrite the method of console.log
    NSString *jsCode = @"console.log = (function(oriLogFunc){\
    return function(str)\
    {\
    if (typeof str === 'string') {window.webkit.messageHandlers.log.postMessage(str);}\
    oriLogFunc.call(console,str);\
    }\
    })(console.log);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)error:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"error"];
    [configuration.userContentController addScriptMessageHandler:_OCLogHelper.shared name:@"error"];
    //rewrite the method of console.error
    NSString *jsCode = @"console.error = (function(oriLogFunc){\
    return function(str)\
    {\
    if (typeof str === 'string') {window.webkit.messageHandlers.error.postMessage(str);}\
    oriLogFunc.call(console,str);\
    }\
    })(console.error);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)warn:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"warn"];
    [configuration.userContentController addScriptMessageHandler:_OCLogHelper.shared name:@"warn"];
    //rewrite the method of console.warn
    NSString *jsCode = @"console.warn = (function(oriLogFunc){\
    return function(str)\
    {\
    if (typeof str === 'string') {window.webkit.messageHandlers.warn.postMessage(str);}\
    oriLogFunc.call(console,str);\
    }\
    })(console.warn);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)debug:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"debug"];
    [configuration.userContentController addScriptMessageHandler:_OCLogHelper.shared name:@"debug"];
    //rewrite the method of console.debug
    NSString *jsCode = @"console.debug = (function(oriLogFunc){\
    return function(str)\
    {\
    if (typeof str === 'string') {window.webkit.messageHandlers.debug.postMessage(str);}\
    oriLogFunc.call(console,str);\
    }\
    })(console.debug);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)info:(WKWebViewConfiguration *)configuration {
    [configuration.userContentController removeScriptMessageHandlerForName:@"info"];
    [configuration.userContentController addScriptMessageHandler:_OCLogHelper.shared name:@"info"];
    //rewrite the method of console.info
    NSString *jsCode = @"console.info = (function(oriLogFunc){\
    return function(str)\
    {\
    if (typeof str === 'string') {window.webkit.messageHandlers.info.postMessage(str);}\
    oriLogFunc.call(console,str);\
    }\
    })(console.info);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}
@end
