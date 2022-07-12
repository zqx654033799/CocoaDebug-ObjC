//
//  WindowHelper.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "WindowHelper.h"
#import "CocoaDebugWindow.h"
#import "CocoaDebugViewController.h"
#import "_DebugCpuMonitor.h"
#import "_DebugFPSMonitor.h"
#import "_DebugMemoryMonitor.h"
#import <objc/runtime.h>

@implementation UIWindow (Extensions)

- (BOOL)computedProperty {
    return [objc_getAssociatedObject(self, @selector(computedProperty)) boolValue];
}
- (void)setComputedProperty:(BOOL)value {
    objc_setAssociatedObject(self, @selector(computedProperty), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionBegan:motion withEvent:event];
    
    [self setComputedProperty:YES];
    
    if (!CocoaDebugSettings.shared.responseShake) { return; }
    if (motion == UIEventSubtypeMotionShake) {
        if (CocoaDebugSettings.shared.visible) { return; }
        CocoaDebugSettings.shared.showBubbleAndWindow = !CocoaDebugSettings.shared.showBubbleAndWindow;
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];

    if ([self computedProperty]) {
        [self setComputedProperty:NO];
        return;
    }
    
    if (!CocoaDebugSettings.shared.responseShake) { return; }
    if (motion == UIEventSubtypeMotionShake) {
        if (CocoaDebugSettings.shared.visible) { return; }
        CocoaDebugSettings.shared.showBubbleAndWindow = !CocoaDebugSettings.shared.showBubbleAndWindow;
    }
}
@end

@interface WindowHelper ()<WindowDelegate>
@property (strong, nonatomic) CocoaDebugWindow *window;
@property (strong, nonatomic) CocoaDebugViewController *vc;

@property (assign, nonatomic) BOOL running;
@end

@implementation WindowHelper

+ (instancetype)shared;
{
    static WindowHelper *onceWindowHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onceWindowHelper = WindowHelper.new;
    });
    return onceWindowHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _window = [[CocoaDebugWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        CGRect windowBounds = self.window.bounds;
        // This is for making the window not to effect the StatusBarStyle
        windowBounds.size.height = UIScreen.mainScreen.bounds.size.height - 0.001;
        _window.bounds = windowBounds;
        _window.rootViewController = self.vc;
    }
    return self;
}

- (CocoaDebugViewController *)vc
{
    if (!_vc) {
        _vc = CocoaDebugViewController.new;
    }
    return _vc;
}

#pragma mark - WindowDelegate
- (BOOL)isPointEvent:(CGPoint)point
{
    return [self.vc shouldReceive:point];
}

- (void)enable
{
    self.window.delegate = self;
    self.window.hidden = NO;
    self.vc.visable = YES;
    
    if (!self.running) {
        self.running = YES;
        [_DebugMemoryMonitor.sharedInstance startMonitoring];
        [_DebugCpuMonitor.sharedInstance startMonitoring];
        [_DebugFPSMonitor.sharedInstance startMonitoring];
    }
    
    if (@available(iOS 13.0, *)) {
        __block BOOL success = NO;
        
        for (int i = 0; i < 10; i++) {
            int64_t delta = (int64_t)(i * 0.1 * NSEC_PER_SEC);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
                if (success) {return;}
                for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                    if ([scene isKindOfClass:UIWindowScene.class]) {
                        self.window.windowScene = scene;
                        success = YES;
                        break;
                    }
                }
            });
        }
    }
}

- (void)disable
{
    self.window.delegate = nil;
    self.window.hidden = NO;
    self.vc.visable = NO;

    if (self.running) {
        self.running = NO;
        [_DebugMemoryMonitor.sharedInstance stopMonitoring];
        [_DebugCpuMonitor.sharedInstance stopMonitoring];
        [_DebugFPSMonitor.sharedInstance stopMonitoring];
    }
}
@end
