//
//  CocoaDebugSettings.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebugSettings.h"
#import "WindowHelper.h"
#import "CocoaDebugViewController.h"
#import "Bubble.h"

@implementation CocoaDebugSettings

+ (instancetype)shared;
{
    static CocoaDebugSettings *onceCocoaDebugSettings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onceCocoaDebugSettings = CocoaDebugSettings.new;
    });
    return onceCocoaDebugSettings;
}

- (BOOL)firstIn {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"firstIn_CocoaDebug"];
}
- (void)setFirstIn:(BOOL)firstIn {
    [[PMUserDefaults standardUserDefaults] setBool:firstIn forKey:@"firstIn_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)responseShake {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"responseShake_CocoaDebug"];
}
- (void)setResponseShake:(BOOL)responseShake {
    [[PMUserDefaults standardUserDefaults] setBool:responseShake forKey:@"responseShake_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)visible {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"visible_CocoaDebug"];
}
- (void)setVisible:(BOOL)visible {
    [[PMUserDefaults standardUserDefaults] setBool:visible forKey:@"visible_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showBubbleAndWindow {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"showBubbleAndWindow_CocoaDebug"];
}
- (void)setShowBubbleAndWindow:(BOOL)showBubbleAndWindow {
    [[PMUserDefaults standardUserDefaults] setBool:showBubbleAndWindow forKey:@"showBubbleAndWindow_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
    
    CGRect bubbleFrame = WindowHelper.shared.vc.bubble.frame;
    CGFloat x = bubbleFrame.origin.x;
    CGFloat width = bubbleFrame.size.width;
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    if (showBubbleAndWindow) {
        if (x > screenWidth/2) {
            bubbleFrame.origin.x = screenWidth - width/8*8.25;
        } else {
            bubbleFrame.origin.x = -width + width/8*8.25;
        }
        WindowHelper.shared.vc.bubble.frame = bubbleFrame;
        [WindowHelper.shared enable];
    } else {
        if (x > screenWidth/2) {
            bubbleFrame.origin.x = screenWidth;
        } else {
            bubbleFrame.origin.x = -width;
        }
        WindowHelper.shared.vc.bubble.frame = bubbleFrame;
        [WindowHelper.shared disable];
    }
}

- (CGFloat)bubbleFrameX {
    return [[PMUserDefaults standardUserDefaults] floatForKey:@"bubbleFrameX_CocoaDebug"];
}
- (void)setBubbleFrameX:(CGFloat)bubbleFrameX {
    [[PMUserDefaults standardUserDefaults] setFloat:bubbleFrameX forKey:@"bubbleFrameX_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (CGFloat)bubbleFrameY {
    return [[PMUserDefaults standardUserDefaults] floatForKey:@"bubbleFrameY_CocoaDebug"];
}
- (void)setBubbleFrameY:(CGFloat)bubbleFrameY {
    [[PMUserDefaults standardUserDefaults] setFloat:bubbleFrameY forKey:@"bubbleFrameY_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)tabBarSelectItem {
    return [[PMUserDefaults standardUserDefaults] integerForKey:@"tabBarSelectItem_CocoaDebug"];
}
- (void)setTabBarSelectItem:(NSInteger)tabBarSelectItem {
    [[PMUserDefaults standardUserDefaults] setInteger:tabBarSelectItem forKey:@"tabBarSelectItem_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)networkLastIndex {
    return [[PMUserDefaults standardUserDefaults] integerForKey:@"networkLastIndex_CocoaDebug"];
}
- (void)setNetworkLastIndex:(NSInteger)networkLastIndex {
    [[PMUserDefaults standardUserDefaults] setInteger:networkLastIndex forKey:@"networkLastIndex_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

#pragma - mark : Log
- (NSInteger)logSelectIndex {
    return [[PMUserDefaults standardUserDefaults] integerForKey:@"logSelectIndex_CocoaDebug"];
}
- (void)setLogSelectIndex:(NSInteger)logSelectIndex {
    [[PMUserDefaults standardUserDefaults] setInteger:logSelectIndex forKey:@"logSelectIndex_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

#pragma - mark : App
- (NSInteger)crashCount {
    return [[PMUserDefaults standardUserDefaults] integerForKey:@"crashCount_CocoaDebug"];
}
- (void)setCrashCount:(NSInteger)crashCount {
    [[PMUserDefaults standardUserDefaults] setInteger:crashCount forKey:@"crashCount_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)crashList {
    NSData *archive = [[PMUserDefaults standardUserDefaults] dataForKey:@"crashArchive_CocoaDebug"];
    if (archive) {
        return [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:archive error:nil];
    }
    return nil;
}
- (void)setCrashList:(NSArray *)crashList {
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:crashList];
    [[PMUserDefaults standardUserDefaults] setData:archive forKey:@"crashArchive_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)slowAnimations {
    return UIApplication.sharedApplication.windows.firstObject.layer.speed < 1.0;
}
- (void)setSlowAnimations:(BOOL)slowAnimations {
    if (slowAnimations) {
        UIApplication.sharedApplication.windows.firstObject.layer.speed = 0.1f;
    } else {
        UIApplication.sharedApplication.windows.firstObject.layer.speed = 1.0f;
    }
}

- (BOOL)disableNetworkMonitoring {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"disableNetworkMonitoring_CocoaDebug"];
}
- (void)setDisableNetworkMonitoring:(BOOL)disable {
    [[PMUserDefaults standardUserDefaults] setBool:disable forKey:@"disableNetworkMonitoring_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)disableLogMonitoring {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"disableLogMonitoring_CocoaDebug"];
}
- (void)setDisableLogMonitoring:(BOOL)disable {
    [[PMUserDefaults standardUserDefaults] setBool:disable forKey:@"disableLogMonitoring_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)enableCrashRecording {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"enableCrashRecording_CocoaDebug"];
}
- (void)setEnableCrashRecording:(BOOL)enable {
    [[PMUserDefaults standardUserDefaults] setBool:enable forKey:@"enableCrashRecording_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)enableWKWebViewMonitoring {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"enableWKWebViewMonitoring_CocoaDebug"];
}
- (void)setEnableWKWebViewMonitoring:(BOOL)enable {
    [[PMUserDefaults standardUserDefaults] setBool:enable forKey:@"enableWKWebViewMonitoring_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)enableMemoryLeaksMonitoring_ViewController {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_UIViewController_CocoaDebug"];
}
- (void)setEnableMemoryLeaksMonitoring_ViewController:(BOOL)enable {
    [[PMUserDefaults standardUserDefaults] setBool:enable forKey:@"enableMemoryLeaksMonitoring_UIViewController_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)enableMemoryLeaksMonitoring_View {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_UIView_CocoaDebug"];
}
- (void)setEnableMemoryLeaksMonitoring_View:(BOOL)enable {
    [[PMUserDefaults standardUserDefaults] setBool:enable forKey:@"enableMemoryLeaksMonitoring_UIView_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)enableMemoryLeaksMonitoring_MemberVariables {
    return [[PMUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug"];
}
- (void)setEnableMemoryLeaksMonitoring_MemberVariables:(BOOL)enable {
    [[PMUserDefaults standardUserDefaults] setBool:enable forKey:@"enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug"];
    [[PMUserDefaults standardUserDefaults] synchronize];
}
@end
