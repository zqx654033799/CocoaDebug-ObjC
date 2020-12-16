//
//  WindowHelper.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <Foundation/Foundation.h>

@class CocoaDebugViewController;
@interface WindowHelper : NSObject

+ (instancetype)shared;

@property (assign, nonatomic) BOOL displayedList;

@property (strong, nonatomic, readonly) CocoaDebugViewController *vc;

- (void)enable;
- (void)disable;

@end
