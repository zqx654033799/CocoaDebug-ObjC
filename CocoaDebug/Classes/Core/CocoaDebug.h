//
//  CocoaDebug.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <Foundation/Foundation.h>

@interface CocoaDebug : NSObject

/**
 *  日志最大数量,默认`1000`
 */
@property (nonatomic, class, readonly) NSInteger logMaxCount;
@property (nonatomic, class, readonly) NSString *mainColor;

+ (void)enable;
+ (void)disable;

@end
