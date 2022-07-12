//
//  CocoaDebugWindow.m
//  Pods
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebugWindow.h"

@implementation CocoaDebugWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.windowLevel = UIWindowLevelStatusBar;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.delegate) {
        return [self.delegate isPointEvent:point];
    }
    return NO;
}
@end
