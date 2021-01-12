//
//  CocoaDebug+Extensions.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebug+Extensions.h"
#import "CocoaDebugSettings.h"
#import "_NetworkHelper.h"
#import <objc/runtime.h>
#import "NSObject+CocoaDebug.h"
#import "_GPBMessage.h"
#import "_OCLogHelper.h"
#import "_CrashHelper.h"

@implementation NSString (Extensions)
- (NSString *)headerString {
    NSString *headerString = self;
    if ([headerString hasPrefix:@"{"]) {
        headerString = [headerString substringFromIndex:1];
    }
    if ([headerString hasSuffix:@"}"]) {
        headerString = [headerString substringToIndex:headerString.length-1];
    }
    headerString = [headerString stringByReplacingOccurrencesOfString:@"\",\"" withString:@"\",\n\""];
    headerString = [headerString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return headerString;
}
@end

@implementation NSDictionary (Extensions)
- (NSData *)dictionaryToData {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
    }
    return nil;
}
- (NSString *)dictionaryToString {
    return self.dictionaryToData.dataToString;
}
- (NSString *)headerToString {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil].dataToString.headerString;
    } @catch (NSException *exception) {
    }
    return nil;
}
@end

@implementation NSData (Extensions)
- (NSString *)dataToString {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
- (NSDictionary *)dataToDictionary {
    @try {
        return [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    } @catch (NSException *exception) {
    }
    return nil;
}
- (NSString *)dataToPrettyPrintString; {
    NSString *str = self.dataToDictionary.dictionaryToString;
    if (str) {
        return str;
    } else {
        _GPBMessage *message = [_GPBMessage parseFromData:self error:nil];
        if (message.serializedSize > 0) {
            return message.description;
        } else {
            return self.dataToString;
        }
    }
}
@end

@implementation UITableView (Extensions)
- (void)tableViewScrollToBottomAnimated:(BOOL)animated; {
    NSInteger numberOfSections = self.numberOfSections;
    NSInteger numberOfRows = [self numberOfRowsInSection:numberOfSections-1];
    if (numberOfRows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:numberOfSections-1];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
- (void)tableViewScrollToHeaderAnimated:(BOOL)animated; {
    [self scrollRectToVisible:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON) animated:animated];
}
@end

@implementation UIColor (Extensions)
+ (NSArray *)colorGradientHead {
    return @[(__bridge id)[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor,
             (__bridge id)[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor];
}

+ (UIColor *)mainGreen {
    return CocoaDebug.mainColor.hexColor;
}
@end

@implementation NSString (Extensions_Color)
- (UIColor *)hexColor {
    return [UIColor colorFromHexString:self];
}
@end

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

@implementation CocoaDebug (Extensions)
+ (void)initializationServerURL:(NSString *)serverURL
                    ignoredURLs:(NSArray *)ignoredURLs
                       onlyURLs:(NSArray *)onlyURLs
       additionalViewController:(UIViewController *)additionalViewController
              emailToRecipients:(NSArray *)emailToRecipients
              emailCcRecipients:(NSArray *)emailCcRecipients
                      mainColor:(NSString *)mainColor
            protobufTransferMap:(NSDictionary<NSString *,NSArray<NSString *> *> *)protobufTransferMap
{
    if (!CocoaDebugSettings.shared.firstIn) {//first launch
        CocoaDebugSettings.shared.firstIn = YES;
        CocoaDebugSettings.shared.showBubbleAndWindow = YES;
    } else {//not first launch
        CocoaDebugSettings.shared.showBubbleAndWindow = CocoaDebugSettings.shared.showBubbleAndWindow;
    }
    CocoaDebugSettings.shared.visible = NO;
    CocoaDebugSettings.shared.responseShake = YES;
    
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
    if (CocoaDebugSettings.shared.enableCrashRecording) {
        _CrashHelper.shared.enable = YES;
    } else {
        _CrashHelper.shared.enable = NO;
    }
}

+ (void)deinitialization
{
    CocoaDebugSettings.shared.responseShake = NO;
    
    _OCLogHelper.shared.enable = NO;
    [_NetworkHelper.shared disable];
    _CrashHelper.shared.enable = NO;
}
@end
