//
//  Bubble.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <UIKit/UIKit.h>

@protocol BubbleDelegate <NSObject>

- (void)didTapBubble;

@end

@interface Bubble : UIView

+ (CGPoint)originalPosition;

- (void)updateOrientation:(CGSize)newSize;

@property (weak, nonatomic) id<BubbleDelegate> delegate;

@end
