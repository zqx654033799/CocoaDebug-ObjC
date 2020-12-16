//
//  CustomTextView.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/10.
//

#import "CustomTextView.h"

@implementation CustomTextView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON)];
        self.backgroundColor = UIColor.clearColor;
        self.scrollEnabled = NO;
        
        self.textColor = UIColor.whiteColor;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        self.font = [UIFont boldSystemFontOfSize:12];
        self.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    else if (action == @selector(select:)) {
        return NO;
    }
    else if (action == @selector(selectAll:)) {
        if (self.selectedTextRange.start == self.beginningOfDocument &&
            self.selectedTextRange.end == self.endOfDocument) {
            return NO;
        }
        return self.text.length > 0;
    }
    return NO;
}
@end
