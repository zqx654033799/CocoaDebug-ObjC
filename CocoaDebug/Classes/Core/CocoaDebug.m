//
//  CocoaDebug.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebug.h"
#import "_NetworkHelper.h"
#import "_OCLogHelper.h"
#import "_CrashHelper.h"

static BOOL debugDidFinishLaunching = NO;

@implementation CocoaDebug

#pragma mark - CocoaDebug enable
+ (void)enable;
{
    if (debugDidFinishLaunching) {
        return;
    }
    debugDidFinishLaunching = YES;

    CocoaDebugSettings.shared.visible = NO;
    CocoaDebugSettings.shared.responseShake = YES;
    CocoaDebugSettings.shared.showBubbleAndWindow = YES;
    
    //slow animations
    CocoaDebugSettings.shared.slowAnimations = NO;
    
    //log
    if (CocoaDebugSettings.shared.disableLogMonitoring) {
        _OCLogHelper.shared.enable = NO;
    } else {
        _OCLogHelper.shared.enable = YES;
    }
    
    //network
    if (CocoaDebugSettings.shared.disableNetworkMonitoring) {
        [_NetworkHelper.shared disable];
    } else {
        [_NetworkHelper.shared enable];
    }
    
    //crash
    if (CocoaDebugSettings.shared.disableCrashRecording) {
        _CrashHelper.shared.enable = NO;
    } else {
        _CrashHelper.shared.enable = YES;
    }
}

#pragma mark - CocoaDebug disable
+ (void)disable;
{
    if (!debugDidFinishLaunching) {
        return;
    }
    debugDidFinishLaunching = NO;

    CocoaDebugSettings.shared.responseShake = NO;
    CocoaDebugSettings.shared.showBubbleAndWindow = NO;

    _OCLogHelper.shared.enable = NO;
    [_NetworkHelper.shared disable];
    _CrashHelper.shared.enable = NO;
}

@end
