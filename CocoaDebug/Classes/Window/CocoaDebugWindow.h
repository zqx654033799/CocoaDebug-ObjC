//
//  CocoaDebugWindow.h
//  Pods
//
//  Created by iPaperman on 2020/12/3.
//

#import <UIKit/UIKit.h>

@protocol WindowDelegate <NSObject>

@required
- (BOOL)isPointEvent:(CGPoint)point;

@end

@interface CocoaDebugWindow : UIWindow

@property (weak, nonatomic) id<WindowDelegate> delegate;

@end
