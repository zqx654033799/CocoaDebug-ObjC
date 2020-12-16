//
//  CocoaDebugSettings.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <Foundation/Foundation.h>

@interface CocoaDebugSettings : NSObject

+ (instancetype)shared;

@property (nonatomic, readwrite) BOOL firstIn;

@property (nonatomic, readwrite) BOOL responseShake;
@property (nonatomic, readwrite) BOOL visible;

/// 显示浮动图层
@property (nonatomic, readwrite) BOOL showBubbleAndWindow;
/// 浮动图层X
@property (nonatomic, readwrite) CGFloat bubbleFrameX;
/// 浮动图层Y
@property (nonatomic, readwrite) CGFloat bubbleFrameY;

@property (nonatomic, readwrite) NSInteger tabBarSelectItem;

@property (nonatomic, readwrite) NSInteger networkLastIndex;

#pragma - mark : Log
@property (nonatomic, readwrite) NSInteger logSelectIndex;

#pragma - mark : App
@property (nonatomic, readwrite) NSInteger crashCount;
@property (nonatomic, readwrite) NSArray *crashList;

@property (nonatomic, readwrite) BOOL slowAnimations;
/// 关闭网络监控
@property (nonatomic, readwrite) BOOL disableNetworkMonitoring;
/// 关闭Log监控
@property (nonatomic, readwrite) BOOL disableLogMonitoring;
/// 开启崩溃记录
@property (nonatomic, readwrite) BOOL enableCrashRecording;
/// 开启WKWebView监控
@property (nonatomic, readwrite) BOOL enableWKWebViewMonitoring;
@property (nonatomic, readwrite) BOOL enableMemoryLeaksMonitoring_ViewController;
@property (nonatomic, readwrite) BOOL enableMemoryLeaksMonitoring_View;
@property (nonatomic, readwrite) BOOL enableMemoryLeaksMonitoring_MemberVariables;

@end
