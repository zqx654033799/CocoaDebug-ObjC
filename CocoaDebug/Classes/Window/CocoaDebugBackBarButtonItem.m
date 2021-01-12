//
//  CocoaDebugBackBarButtonItem.m
//  CocoaDebug
//
//  Created by iPaperman on 2021/1/8.
//

#import "CocoaDebugBackBarButtonItem.h"

@implementation CocoaDebugBackBarButtonItem

+ (instancetype)backBarButtonItem {
    return [[self alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (UIMenu *)menu { // iOS14 Disable Long Press back Button (callout menu)
    return nil;
}
@end
