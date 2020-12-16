//
//  AppInfoModel.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/8.
//

#import "AppInfoModel.h"
#import "CocoaDebugSettings.h"
#include <sys/utsname.h>

NSNotificationName const AppInfoChangedNeedRestartNotification = @"_AppInfoChangedNeedRestartNotification";

@interface AppInfoModel ()
@property (copy, nonatomic) BOOL (^valueBlock)(void);
@end

@implementation AppInfoModel
+ (NSString *)screenSizeInInches
{
    float scale = [[UIScreen mainScreen] scale];

    float ppi = scale * ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 132 : 163);

    float width = ([[UIScreen mainScreen] bounds].size.width * scale);
    float height = ([[UIScreen mainScreen] bounds].size.height * scale);

    float horizontal = width / ppi, vertical = height / ppi;

    float diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2));
    
    return [NSString stringWithFormat:@"%.01f", diagonal];
}

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceModel;
}

+ (NSArray<NSDictionary<NSString *, NSArray<AppInfoModel *> *> *> *)infos;
{
    //Crash report
    AppInfoModel *crashIM = [AppInfoModel new];
    crashIM.image = [UIImage imageNamed:@"_icon_file_type_bugs" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    crashIM.leftString = @"crash";
    crashIM.rightString = [NSString stringWithFormat:@"%zd", CocoaDebugSettings.shared.crashCount];
    NSDictionary *crashD = @{@"Crash report": @[crashIM]};
    //Application informations
    AppInfoModel *versionM = [AppInfoModel new];
    versionM.leftString = @"version";
    versionM.rightString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    AppInfoModel *buildM = [AppInfoModel new];
    buildM.leftString = @"build";
    buildM.rightString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    AppInfoModel *bundleNameM = [AppInfoModel new];
    bundleNameM.leftString = @"bundle name";
    bundleNameM.rightString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge id)kCFBundleNameKey];
    AppInfoModel *bundleIdM = [AppInfoModel new];
    bundleIdM.leftString = @"bundle id";
    bundleIdM.rightString = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *appInfoD = @{@"Application informations": @[versionM,buildM,bundleNameM,bundleIdM]};
    //Device
    AppInfoModel *screenResolutionM = [AppInfoModel new];
    screenResolutionM.leftString = @"screen resolution";
    screenResolutionM.rightString = NSStringFromCGSize(UIScreen.mainScreen.currentMode.size);
    AppInfoModel *screenSizeM = [AppInfoModel new];
    screenSizeM.leftString = @"screen size";
    screenSizeM.rightString = [self screenSizeInInches];
    AppInfoModel *deviceNM = [AppInfoModel new];
    deviceNM.leftString = @"device name";
    deviceNM.rightString = UIDevice.currentDevice.name;
    AppInfoModel *deviceTM = [AppInfoModel new];
    deviceTM.leftString = @"device type";
    deviceTM.rightString = [self deviceModel];
    AppInfoModel *osVersionM = [AppInfoModel new];
    osVersionM.leftString = @"iOS version";
    osVersionM.rightString = UIDevice.currentDevice.systemVersion;
    NSDictionary *deviceD = @{@"Device": @[screenResolutionM,screenSizeM,deviceNM,deviceTM,osVersionM]};
    //Debug
    AppInfoModel *slowAnimM = [AppInfoModel new];
    slowAnimM.leftString = @"slow animations";
    slowAnimM.rightString = @"";
    slowAnimM.accessoryView = UISwitch.new;
    slowAnimM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.slowAnimations;
    };
    [slowAnimM.accessoryView addTarget:slowAnimM action:@selector(slowAnimationsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *debugD = @{@"Debug": @[slowAnimM]};
    //Monitor
    AppInfoModel *networkM = [AppInfoModel new];
    networkM.leftString = @"network";
    networkM.rightString = nil;
    networkM.accessoryView = UISwitch.new;
    networkM.valueBlock = ^BOOL{
        return !CocoaDebugSettings.shared.disableNetworkMonitoring;
    };
    [networkM.accessoryView addTarget:networkM action:@selector(networkSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *logM = [AppInfoModel new];
    logM.leftString = @"log";
    logM.rightString = nil;
    logM.accessoryView = UISwitch.new;
    logM.valueBlock = ^BOOL{
        return !CocoaDebugSettings.shared.disableLogMonitoring;
    };
    [logM.accessoryView addTarget:logM action:@selector(logSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *crashSM = [AppInfoModel new];
    crashSM.leftString = @"crash";
    crashSM.rightString = nil;
    crashSM.accessoryView = UISwitch.new;
    crashSM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.enableCrashRecording;
    };
    [crashSM.accessoryView addTarget:crashSM action:@selector(crashSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *webViewM = [AppInfoModel new];
    webViewM.leftString = @"WKWebView";
    webViewM.rightString = nil;
    webViewM.accessoryView = UISwitch.new;
    webViewM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.enableWKWebViewMonitoring;
    };
    [webViewM.accessoryView addTarget:webViewM action:@selector(webViewSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *uvcM = [AppInfoModel new];
    uvcM.leftString = @"UIViewController memory leaks";
    uvcM.rightString = @"";
    uvcM.accessoryView = UISwitch.new;
    uvcM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_ViewController;
    };
    [uvcM.accessoryView addTarget:uvcM action:@selector(controllerMemoryLeaksSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *uvM = [AppInfoModel new];
    uvM.leftString = @"UIView memory leaks";
    uvM.rightString = nil;
    uvM.accessoryView = UISwitch.new;
    uvM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_View;
    };
    [uvM.accessoryView addTarget:uvM action:@selector(viewMemoryLeaksSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *mvM = [AppInfoModel new];
    mvM.leftString = @"member variables memory leaks";
    mvM.rightString = nil;
    mvM.accessoryView = UISwitch.new;
    mvM.valueBlock = ^BOOL{
        return CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_MemberVariables;
    };
    [mvM.accessoryView addTarget:mvM action:@selector(memberVariablesMemoryLeaksSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *monitorD = @{@"Monitor": @[networkM,logM,crashSM,webViewM,uvcM,uvM,mvM]};
    //General
    AppInfoModel *aboutM = [AppInfoModel new];
    aboutM.leftString = @"about";
    aboutM.rightString = @"CocoaDebug 1.4.8";
    NSDictionary *generalD = @{@"General": @[aboutM]};
    
    return @[crashD, appInfoD, deviceD, debugD, monitorD, generalD];
}

- (UISwitch *)accessoryView {
    if (_accessoryView) {
        _accessoryView.on = self.valueBlock ? self.valueBlock() : NO;
    }
    return _accessoryView;
}

- (void)slowAnimationsSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.slowAnimations = sender.on;
}

- (void)networkSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.disableNetworkMonitoring = !sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)logSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.disableLogMonitoring = !sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)crashSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.enableCrashRecording = sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)webViewSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.enableWKWebViewMonitoring = sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)controllerMemoryLeaksSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_ViewController = sender.on;
}

- (void)viewMemoryLeaksSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_View = sender.on;
}

- (void)memberVariablesMemoryLeaksSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.enableMemoryLeaksMonitoring_MemberVariables = sender.on;
}
@end
