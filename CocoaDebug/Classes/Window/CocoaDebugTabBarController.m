//
//  CocoaDebugTabBarController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/7.
//

#import "CocoaDebugTabBarController.h"
#import "CocoaDebugSettings.h"
#import "WindowHelper.h"
#import "CocoaDebugNavigationController.h"
#import "NetworkViewController.h"
#import "LogViewController.h"
#import "_Sandboxer.h"
#import "AppInfoViewController.h"
#import "CocoaDebug+Extensions.h"

@interface CocoaDebugTabBarController ()<UITabBarDelegate>

@end

@implementation CocoaDebugTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    
    [self setChildControllers];
    
    self.selectedIndex = CocoaDebugSettings.shared.tabBarSelectItem;
    self.tabBar.barTintColor = UIColor.blackColor;
    self.tabBar.tintColor = UIColor.mainGreen;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CocoaDebugSettings.shared.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    CocoaDebugSettings.shared.visible = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    WindowHelper.shared.displayedList = NO;
}

//MARK: - private
- (void)setChildControllers
{    
    //1.
    UINavigationController *network = [[CocoaDebugNavigationController alloc] initWithRootViewController:NetworkViewController.new];
    UINavigationController *logs = [[CocoaDebugNavigationController alloc] initWithRootViewController:LogViewController.new];
    UINavigationController *sandbox = _Sandboxer.shared.homeDirectoryNavigationController;
    UINavigationController *app = [[CocoaDebugNavigationController alloc] initWithRootViewController:AppInfoViewController.new];
    
    //2.
    _Sandboxer.shared.systemFilesHidden = NO;
    _Sandboxer.shared.extensionHidden = NO;
    _Sandboxer.shared.shareable = YES;
    _Sandboxer.shared.fileDeletable = YES;
    _Sandboxer.shared.directoryDeletable = YES;
    network.title = @"Network";
    network.tabBarItem.image = [UIImage imageNamed:@"_icon_file_type_network" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    logs.title = @"Logs";
    logs.tabBarItem.image = [UIImage imageNamed:@"_icon_file_type_logs" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    sandbox.title = @"Sandbox";
    sandbox.tabBarItem.image = [UIImage imageNamed:@"_icon_file_type_sandbox" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    app.title = @"App";
    app.tabBarItem.image = [UIImage imageNamed:@"_icon_file_type_app" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    self.viewControllers = @[network, logs, sandbox, app];
    for (UIViewController *vc in self.viewControllers) {
        [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.mainGreen} forState:UIControlStateSelected];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [tabBar.items indexOfObject:item];
    if (index != NSNotFound) {
        CocoaDebugSettings.shared.tabBarSelectItem = index;
    }
}
@end
