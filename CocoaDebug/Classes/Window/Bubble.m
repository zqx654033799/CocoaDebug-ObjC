//
//  Bubble.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "Bubble.h"
#import "_HttpDatasource.h"
#import "_DebugConsoleLabel.h"
#import "_DebugCpuMonitor.h"
#import "_DebugFPSMonitor.h"
#import "_DebugMemoryMonitor.h"
#import "_OCLogStoreManager.h"

static CGFloat const _width  = 60;
static CGFloat const _height = 60;

@interface Bubble ()
@property (strong, nonatomic) _DebugConsoleLabel *memoryLabel;
@property (strong, nonatomic) _DebugConsoleLabel *fpsLabel;
@property (strong, nonatomic) _DebugConsoleLabel *cpuLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (assign, nonatomic, readonly) NSInteger networkNumber;
@end

@implementation Bubble

+ (CGPoint)originalPosition {
    if (CocoaDebugSettings.shared.bubbleFrameX != 0 && CocoaDebugSettings.shared.bubbleFrameY != 0) {
        return CGPointMake(CocoaDebugSettings.shared.bubbleFrameX, CocoaDebugSettings.shared.bubbleFrameY);
    }
    return CGPointMake(1.875 + _width/2, 200);
}

- (void)updateOrientation:(CGSize)newSize {
    CGSize oldSize = CGSizeMake(newSize.height, newSize.width);
    CGFloat percent = self.center.y / oldSize.height * 100;
    CGFloat newOrigin = newSize.height * percent / 100;
    CGFloat originX = self.frame.origin.x < newSize.height / 2 ? _width/8*4.25 : newSize.width - _width/8*4.25;
    self.center = CGPointMake(originX, newOrigin);
}

- (void)initLabelContent:(NSString *)content {
    if ([@"🚀" isEqualToString:content] || [@"❌" isEqualToString:content]) {
        //step 0
        CGFloat const WH = 25;
        //step 1
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = content;
        //step 2
        label.frame = CGRectMake(self.frame.size.width/2 - WH/2, self.frame.size.height/2 - WH/2, WH, WH);
        [self addSubview:label];
        //step 3
        [UIView animateWithDuration:0.8 animations:^{
            CGRect rect = label.frame;
            rect.origin.y = -80;
            label.frame = rect;
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, _width, _height)];
    if (self) {
        [self initLayer];
        
        SEL selector = @selector(panDidFire:);
        id panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:selector];
        [self addGestureRecognizer:panGesture];
        
        //notification
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadHttp_notification:) name:@"reloadHttp_CocoaDebug" object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadHttp_notification:) name:HttpModelsChangedNotification object:nil];
        
        //Defaults
        self.memoryLabel.attributedText = [self.memoryLabel memoryAttributedStringWith:0];
        self.cpuLabel.attributedText = [self.cpuLabel cpuAttributedStringWith:0];
        self.fpsLabel.attributedText = [self.fpsLabel fpsAttributedStringWith:60];
        
        //Memory
        [_DebugMemoryMonitor.sharedInstance setValueBlock:^(float value) {
            [self.memoryLabel updateLabelWith:_DebugToolLabelTypeMemory value:value];
        }];
        //CPU
        [_DebugCpuMonitor.sharedInstance setValueBlock:^(float value) {
            [self.cpuLabel updateLabelWith:_DebugToolLabelTypeCPU value:value];
        }];
        //FPS
        [_DebugFPSMonitor.sharedInstance setValueBlock:^(float value) {
            [self.fpsLabel updateLabelWith:_DebugToolLabelTypeFPS value:value];
        }];
    }
    return self;
}

- (NSInteger)networkNumber {
    return [_HttpDatasource.shared.httpModels count];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)initLayer {
    self.backgroundColor = UIColor.blackColor;
    self.layer.cornerRadius = 10;
    [self sizeToFit];
    
    CAGradientLayer *gradientLayer = CAGradientLayer.new;
    gradientLayer.frame = self.bounds;
    gradientLayer.cornerRadius = 10;
    
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.00].CGColor,
                             (__bridge id)[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.00].CGColor];
    [self.layer addSublayer:gradientLayer];
    
    self.numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.numberLabel.layer.cornerRadius = 10;
    self.numberLabel.layer.masksToBounds = YES;
    self.numberLabel.backgroundColor = UIColor.redColor;
    self.numberLabel.text = [@(self.networkNumber) stringValue];
    self.numberLabel.textColor = UIColor.whiteColor;
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    self.numberLabel.adjustsFontSizeToFitWidth = YES;
    self.numberLabel.hidden = YES;
    [self addSubview:self.numberLabel];
    
    self.numberLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    
    if (CocoaDebugSettings.shared.bubbleFrameX > (UIScreen.mainScreen.bounds.size.width / 2)) {
        self.numberLabel.frame = CGRectMake(-10, -10, 20, 20);
    } else {
        self.numberLabel.frame = CGRectMake(_width - 10, -10, 20, 20);
    }
    
    self.memoryLabel = [[_DebugConsoleLabel alloc] initWithFrame:CGRectMake(0, 7, _width, 14)];
    self.fpsLabel = [[_DebugConsoleLabel alloc] initWithFrame:CGRectMake(0, 23, _width, 14)];
    self.cpuLabel = [[_DebugConsoleLabel alloc] initWithFrame:CGRectMake(0, 39, _width, 14)];
    
    [self addSubview:self.memoryLabel];
    [self addSubview:self.fpsLabel];
    [self addSubview:self.cpuLabel];
    
    id tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tapGesture];
    
    id longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap)];
    [self addGestureRecognizer:longTap];
}

- (void)changeSideDisplay {
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
    } completion:NULL];
}

#pragma - mark: - notification
- (void)reloadHttp_notification:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (notification.userInfo) {
            NSString *statusCode = notification.userInfo[@"statusCode"];
            
            if ([_successStatusCodes containsObject:statusCode]) {
                [weakSelf initLabelContent:@"🚀"];
            }
            else if ([@"0" isEqualToString:statusCode]) { //"0" means network unavailable
                [weakSelf initLabelContent:@"❌"];
            }
            else {
                if (!statusCode) {return;}
                [weakSelf initLabelContent:statusCode];
            }
        }
        
        weakSelf.numberLabel.text = [@(weakSelf.networkNumber) stringValue];
        weakSelf.numberLabel.hidden = weakSelf.networkNumber == 0;
    });
}

#pragma - mark: - target action
- (void)tap {
    if (self.delegate) {
        [self.delegate didTapBubble];
    }
}

- (void)longTap {
    [_OCLogStoreManager.shared reset];
    [_HttpDatasource.shared reset];
}

- (void)panDidFire:(UIPanGestureRecognizer *)panner {
    __weak typeof(self) weakSelf = self;
    if (panner.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            weakSelf.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:NULL];
    }
    
    CGPoint offset = [panner translationInView:self.superview];
    [panner setTranslation:CGPointZero inView:self.superview];
    CGPoint center = self.center;
    center.x += offset.x;
    center.y += offset.y;
    self.center = center;
    
    if (panner.state == UIGestureRecognizerStateEnded || panner.state == UIGestureRecognizerStateCancelled) {
        UIEdgeInsets frameInset;
        
        if (@available(iOS 11.0, *)) {
            if (UIEdgeInsetsEqualToEdgeInsets(UIApplication.sharedApplication.keyWindow.safeAreaInsets, UIEdgeInsetsZero)) {
                frameInset = UIEdgeInsetsMake(UIApplication.sharedApplication.statusBarFrame.size.height, 0, 0, 0);
            } else {
                frameInset = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
            }
        } else {
            frameInset = UIDevice.currentDevice.orientation == UIInterfaceOrientationPortrait ? UIEdgeInsetsMake(UIApplication.sharedApplication.statusBarFrame.size.height, 0, 0, 0) : UIEdgeInsetsZero;
        }
        
        CGPoint location = [panner locationInView:self.superview];
        CGPoint velocity = [panner velocityInView:self.superview];
        
        CGFloat finalX = _width/8*4.25;
        CGFloat finalY = location.y;
        
        CGFloat const screenWidth = UIScreen.mainScreen.bounds.size.width;
        if (location.x > screenWidth / 2) {
            finalX = screenWidth - finalX;
            self.numberLabel.frame = CGRectMake(-10, -10, 20, 20);
        } else {
            self.numberLabel.frame = CGRectMake(_width - 10, -10, 20, 20);
        }
        
        [self changeSideDisplay];
        
        CGFloat horizentalVelocity = fabs(velocity.x);
        CGFloat positionX = fabs(finalX - location.x);
        
        CGFloat velocityForce = sqrt(pow(velocity.x, 2) * pow(velocity.y, 2));
        
        CGFloat durationAnimation = (velocityForce > 1000.0) ? fmin(0.3, positionX / horizentalVelocity) : 0.3;
        
        if (velocityForce > 1000.0) {
            finalY += velocity.y * durationAnimation;
        }
        
        CGFloat const screenHeight = UIScreen.mainScreen.bounds.size.height;
        CGFloat const cy = _height/8*4.25;
        if (finalY > screenHeight - cy) {
            finalY = screenHeight - frameInset.bottom - cy;
        } else if (finalY < cy + frameInset.top) {
            finalY = cy + frameInset.top;
        }
        
        CocoaDebugSettings.shared.bubbleFrameX = finalX;
        CocoaDebugSettings.shared.bubbleFrameY = finalY;
        
        [UIView animateWithDuration:durationAnimation * 5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            weakSelf.center = CGPointMake(finalX, finalY);
            weakSelf.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }
}
@end
