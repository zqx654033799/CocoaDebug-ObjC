//
//  CocoaDebugNavigationController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/7.
//

#import "CocoaDebugNavigationController.h"
#import "CocoaDebug+Extensions.h"
#import "CocoaDebugSettings.h"

@interface CocoaDebugNavigationController ()

@end

@implementation CocoaDebugNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    
    self.navigationBar.tintColor = UIColor.mainGreen;
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                               NSForegroundColorAttributeName: self.navigationBar.tintColor};
    
    self.navigationBar.barTintColor = [@"#1F2124" hexColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if (!rootViewController.title) {
        rootViewController.title = self.title;
    }
    if (!rootViewController.navigationItem.leftBarButtonItem) {
        SEL selector = @selector(exit);
        UIImage *image = [UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:selector];
    }
}

- (void)exit {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
