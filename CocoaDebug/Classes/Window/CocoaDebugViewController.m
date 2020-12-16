//
//  CocoaDebugViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebugViewController.h"
#import "WindowHelper.h"
#import "Bubble.h"
#import "CocoaDebugTabBarController.h"

@interface CocoaDebugViewController ()<BubbleDelegate>
@property (strong, nonatomic) Bubble *bubble;
@end

@implementation CocoaDebugViewController

- (Bubble *)bubble {
    if (!_bubble) {
        _bubble = Bubble.new;
    }
    return _bubble;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view addSubview:self.bubble];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [self.bubble updateOrientation:size];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bubble.center = Bubble.originalPosition;
    self.bubble.delegate = self;
    self.view.backgroundColor = UIColor.clearColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WindowHelper.shared.displayedList = NO;
}

- (BOOL)shouldReceive:(CGPoint)point
{
    if (WindowHelper.shared.displayedList) {
        return YES;
    }
    return CGRectContainsPoint(self.bubble.frame, point);
}

#pragma mark - d
- (void)didTapBubble
{
    WindowHelper.shared.displayedList = YES;
    UIViewController *manager = CocoaDebugTabBarController.new;
    manager.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:manager animated:YES completion:NULL];
}
@end
