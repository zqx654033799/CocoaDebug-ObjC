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
#import "_OCLogStoreManager.h"
#import "_HttpDatasource.h"

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.visable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bubble.center = Bubble.originalPosition;
    self.bubble.delegate = self;
    self.view.backgroundColor = UIColor.clearColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [_OCLogStoreManager.shared reset];
    [_HttpDatasource.shared reset];
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

- (void)setVisable:(BOOL)visable {
    _visable = visable;
    if (self.viewLoaded) {
        self.view.hidden = !visable;
    }
}

#pragma mark - BubbleDelegate
- (void)didTapBubble
{
    WindowHelper.shared.displayedList = YES;
    UIViewController *manager = CocoaDebugTabBarController.new;
    manager.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:manager animated:YES completion:NULL];
}
@end
