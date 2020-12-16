//
//  CocoaDebugViewController.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <UIKit/UIKit.h>

@class Bubble;
@interface CocoaDebugViewController : UIViewController

@property (strong, nonatomic, readonly) Bubble *bubble;
- (BOOL)shouldReceive:(CGPoint)point;

@end
