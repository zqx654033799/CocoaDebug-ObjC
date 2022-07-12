//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 异步执行block
FOUNDATION_EXPORT void cocoadebug_async_run_queue(dispatch_block_t block);

/// 主线程执行block
FOUNDATION_EXPORT void cocoadebug_async_run_main(dispatch_block_t block);

/// 方法交换
FOUNDATION_EXPORT void cocoadebug_swizzlingForInstance(Class theClass, SEL originalSelector, SEL swizzledSelector);
/// 方法交换
FOUNDATION_EXPORT void cocoadebug_swizzlingForClass(Class theClass, SEL originalSelector, SEL swizzledSelector);

/// tmp/CocoaDebug/pathComponent工作目录
FOUNDATION_EXPORT NSString *cocoadebug_workDirectory(NSString *pathComponent);

/*************************************************/

@interface NSData (CocoaDebug)
+ (NSData *)dataWithInputStream:(NSInputStream *)stream;

@property (readonly) NSString *dataToString;
@property (readonly) id dataToObject;
@property (readonly) NSString *dataToPrettyPrintString;

// 获取一定字节长度的字符串
- (NSString *)fetchStringWithByteLength:(NSUInteger)length;
@end

@interface NSString (CocoaDebug)
@property (nonatomic, readonly) UIColor *hexColor;
@property (readonly) NSString *headerString;

// 获取一定字节长度的字符串
- (NSString *)fetchStringWithByteLength:(NSUInteger)length;
@end

@interface NSDictionary (CocoaDebug)
@property (readonly) NSData *objectToData;
@property (readonly) NSString *objectToString;
@property (readonly) NSString *headerToString;
@end

@interface NSArray (CocoaDebug)
@property (readonly) NSData *objectToData;
@property (readonly) NSString *objectToString;
@end

@interface NSDate (CocoaDebug)
- (NSString *)format;
@end

/*************************************************/

@interface UIColor (CocoaDebug)
@property (copy, nonatomic, class, readonly) UIColor *mainGreen;

+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

/*************************************************/

@interface UIImage (CocoaDebug)

/** 根据一个GIF图片的data数据 获得GIF image对象 */
+ (UIImage *)imageWithGIFData:(NSData *)data;
+ (UIImage *)imageWithGIFURL:(NSURL *)url;

@end

@interface UITableView (CocoaDebug)
- (void)tableViewScrollToBottomAnimated:(BOOL)animated;
- (void)tableViewScrollToHeaderAnimated:(BOOL)animated;
@end

@interface NSURLSessionTask (CocoaDebug)
@property (readonly) NSString *cocoadebugUID;
@end
