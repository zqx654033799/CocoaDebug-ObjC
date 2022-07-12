//
//  AppInfoModel.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/8.
//

#import "AppInfoModel.h"
#include <sys/utsname.h>
#import <WebKit/WebKit.h>

NSNotificationName const AppInfoChangedNeedRestartNotification = @"_AppInfoChangedNeedRestartNotification";

@interface AppInfoModel ()
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
    slowAnimM.accessoryView.on = CocoaDebugSettings.shared.slowAnimations;
    [slowAnimM.accessoryView addTarget:slowAnimM action:@selector(slowAnimationsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *restoreUserDefaultsM = [AppInfoModel new];
    restoreUserDefaultsM.leftString = @"清除缓存数据";
    restoreUserDefaultsM.rightString = @"";
    restoreUserDefaultsM.accessoryView = UISwitch.new;
    [restoreUserDefaultsM.accessoryView addTarget:restoreUserDefaultsM action:@selector(restoreUserDefaultsChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *restoreAppM = [AppInfoModel new];
    restoreAppM.leftString = @"清除所有数据";
    restoreAppM.rightString = @"";
    restoreAppM.accessoryView = UISwitch.new;
    [restoreAppM.accessoryView addTarget:restoreAppM action:@selector(restoreAppSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *showSettingM = [AppInfoModel new];
    showSettingM.leftString = @"打开\"设置\"";
    showSettingM.rightString = @"";
    showSettingM.accessoryView = UISwitch.new;
    [showSettingM.accessoryView addTarget:showSettingM action:@selector(showSettingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *debugD = @{@"Debug": @[slowAnimM,restoreUserDefaultsM,restoreAppM,showSettingM]};
    //Monitor
    AppInfoModel *networkM = [AppInfoModel new];
    networkM.leftString = @"network";
    networkM.rightString = nil;
    networkM.accessoryView = UISwitch.new;
    networkM.accessoryView.on = !CocoaDebugSettings.shared.disableNetworkMonitoring;
    [networkM.accessoryView addTarget:networkM action:@selector(networkSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *logM = [AppInfoModel new];
    logM.leftString = @"log";
    logM.rightString = nil;
    logM.accessoryView = UISwitch.new;
    logM.accessoryView.on = !CocoaDebugSettings.shared.disableLogMonitoring;
    [logM.accessoryView addTarget:logM action:@selector(logSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *crashSM = [AppInfoModel new];
    crashSM.leftString = @"crash";
    crashSM.rightString = nil;
    crashSM.accessoryView = UISwitch.new;
    crashSM.accessoryView.on = !CocoaDebugSettings.shared.disableCrashRecording;
    [crashSM.accessoryView addTarget:crashSM action:@selector(crashSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    AppInfoModel *webViewM = [AppInfoModel new];
    webViewM.leftString = @"WKWebView";
    webViewM.rightString = nil;
    webViewM.accessoryView = UISwitch.new;
    webViewM.accessoryView.on = !CocoaDebugSettings.shared.disableWKWebViewMonitoring;
    [webViewM.accessoryView addTarget:webViewM action:@selector(webViewSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *monitorD = @{@"Monitor": @[networkM,logM,crashSM,webViewM]};
    //General
    AppInfoModel *aboutM = [AppInfoModel new];
    aboutM.leftString = @"about";
    aboutM.rightString = @"CocoaDebug 1.0.1";
    NSDictionary *generalD = @{@"General": @[aboutM]};
    
    return @[crashD, appInfoD, deviceD, debugD, monitorD, generalD];
}

- (void)slowAnimationsSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.slowAnimations = sender.on;
}

- (void)restoreUserDefaultsChanged:(UISwitch *)sender {
    // 清空UserDefaults
    [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
    // 清空WK缓存
    [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:WKWebsiteDataStore.allWebsiteDataTypes modifiedSince:NSDate.distantPast completionHandler:^{}];
    // 清空tmp
    NSArray *deletePaths = @[NSTemporaryDirectory()];
    for (id deletePath in deletePaths) {
        NSArray *contentsName = [NSFileManager.defaultManager contentsOfDirectoryAtPath:deletePath error:nil];
        for (id name in contentsName) {
            id path = [deletePath stringByAppendingPathComponent:name];
            [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)restoreAppSwitchChanged:(UISwitch *)sender {
    // 清空UserDefaults
    [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
    // 清空WK缓存
    [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:WKWebsiteDataStore.allWebsiteDataTypes modifiedSince:NSDate.distantPast completionHandler:^{}];
    // 清空钥匙串
    NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                           (__bridge id)kSecClassInternetPassword,
                           (__bridge id)kSecClassCertificate,
                           (__bridge id)kSecClassKey,
                           (__bridge id)kSecClassIdentity];
    for (id secItemClass in secItemClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
    // 清空Document
    // 清空Library/Caches
    NSArray *deletePaths = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
                             [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
    for (id deletePath in deletePaths) {
        NSArray *contentsName = [NSFileManager.defaultManager contentsOfDirectoryAtPath:deletePath error:nil];
        for (id name in contentsName) {
            id path = [deletePath stringByAppendingPathComponent:name];
            [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)showSettingSwitchChanged:(UISwitch *)sender {
    [sender setOn:NO];
    if (@available(iOS 10.0, *)) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:NULL];
    } else {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
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
    CocoaDebugSettings.shared.disableCrashRecording = !sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)webViewSwitchChanged:(UISwitch *)sender {
    CocoaDebugSettings.shared.disableWKWebViewMonitoring = !sender.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppInfoChangedNeedRestartNotification object:nil];
}
@end
