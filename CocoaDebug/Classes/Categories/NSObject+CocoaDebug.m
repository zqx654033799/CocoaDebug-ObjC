//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "NSObject+CocoaDebug.h"
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>

void cocoadebug_async_run_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void cocoadebug_async_run_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void cocoadebug_swizzlingForInstance(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    
    //源方法不存在就直接添加 对应的IMP
    if (originalMethod == nil) {
        return;
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

FOUNDATION_EXPORT void cocoadebug_swizzlingForClass(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(theClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(theClass, swizzledSelector);
    
    //源方法不存在就直接添加 对应的IMP
    if (originalMethod == nil) {
        return;
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

NSString *cocoadebug_workDirectory(NSString *pathComponent) {
    NSFileManager *fm = NSFileManager.defaultManager;
    @synchronized (fm) {
        NSString *rootPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CocoaDebug"];
        if (![fm fileExistsAtPath:rootPath]) {
            [fm createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (!pathComponent) {
            return rootPath;
        }
        NSString *workPath = [rootPath stringByAppendingPathComponent:pathComponent];
        if (pathComponent.pathExtension.length == 0) {
            if (![fm fileExistsAtPath:workPath]) {
                [fm createDirectoryAtPath:workPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        return workPath;
    }
}

/*************************************************/

@implementation NSData (CocoaDebug)
+ (NSData *)dataWithInputStream:(NSInputStream *)stream
{
    NSMutableData * data = [NSMutableData data];
    [stream open];
    NSInteger result;
    uint8_t buffer[1024]; // BUFFER_LEN can be any positive integer
    
    while((result = [stream read:buffer maxLength:1024]) != 0) {
        if (result > 0) {
            // buffer contains result bytes of data to be handled
            [data appendBytes:buffer length:result];
        } else {
            // The stream had an error. You can get an NSError object using [iStream streamError]
            if (result < 0) {
                // [NSException raise:@"STREAM_ERROR" format:@"%@", [stream streamError]];
                return nil;//liman
            }
        }
    }
    return data;
}
- (NSString *)dataToString {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
- (id)dataToObject {
    @try {
        return [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    } @catch (NSException *exception) {
    }
    return nil;
}
- (NSString *)dataToPrettyPrintString; {
    NSString *str = [self.dataToObject objectToString];
    if (str) {
        return str;
    } else {
        return self.dataToString;
    }
}

// 获取一定字节长度的字符串
- (NSString *)fetchStringWithByteLength:(NSUInteger)length;
{
    if (self.length <= length) {
        length = self.length;
    }
    //make sure to use a loop to get a not nil string.
    //because your certain length data may be not decode by NSString
    //for循环次数限制，避免影响性能
    NSUInteger min = MAX(length - 5, 0);
    for (NSUInteger i = length; i > min; i--) {

        @autoreleasepool {
            NSData *data = [self subdataWithRange:NSMakeRange(0, i)];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (string) {
                return string;
            }
        }

    }
    return @"";
}
@end

@implementation NSString (CocoaDebug)
- (NSString *)headerString {
    NSString *headerString = self;
    if ([headerString hasPrefix:@"{"]) {
        headerString = [headerString substringFromIndex:1];
    }
    if ([headerString hasSuffix:@"}"]) {
        headerString = [headerString substringToIndex:headerString.length-1];
    }
    headerString = [headerString stringByReplacingOccurrencesOfString:@"\",\"" withString:@"\",\n\""];
    headerString = [headerString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return headerString;
}
- (UIColor *)hexColor {
    return [UIColor colorFromHexString:self];
}
- (NSString *)fetchStringWithByteLength:(NSUInteger)length; {
    NSData *originalData = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (originalData.length <= length) {
        return self;
    }

    return [originalData fetchStringWithByteLength:length];
}
@end

@implementation NSDictionary (CocoaDebug)
- (NSData *)objectToData {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
    }
    return nil;
}
- (NSString *)objectToString {
    return self.objectToData.dataToString;
}
- (NSString *)headerToString {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil].dataToString.headerString;
    } @catch (NSException *exception) {
    }
    return nil;
}
@end

@implementation NSArray (CocoaDebug)
- (NSData *)objectToData {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
    }
    return nil;
}
- (NSString *)objectToString {
    return self.objectToData.dataToString;
}
- (NSString *)headerToString {
    @try {
        return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil].dataToString.headerString;
    } @catch (NSException *exception) {
    }
    return nil;
}
@end

@implementation NSDate (CocoaDebug)
- (NSString *)format;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return [formatter stringFromDate:self];
}
@end

/*************************************************/

@implementation UIColor (CocoaDebug)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)mainGreen {
    return [@"#42d459" hexColor];
}
@end

/*************************************************/

@implementation UIImage (CocoaDebug)

/** 根据一个GIF图片的data数据 获得GIF image对象 */
+ (UIImage *)imageWithGIFURL:(NSURL *)url {
    if (!url) return nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    UIImage *animatedImage = [self imageSourceRef:source];
    if (!animatedImage) {
        animatedImage = [[UIImage alloc] initWithContentsOfFile:url.relativePath];
    }
    
    // 释放源Gif图片
    CFRelease(source);
    
    return animatedImage;
}

+ (UIImage *)imageWithGIFData:(NSData *)data {
    if (!data) return nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                          (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});
    UIImage *animatedImage = [self imageSourceRef:source];
    if (!animatedImage) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    
    // 释放源Gif图片
    CFRelease(source);
    
    return animatedImage;
}

+ (UIImage *)imageSourceRef:(CGImageSourceRef)source {
    if (!source) {
        return nil;
    }
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage = nil;
    
    if (count > 1) {
        // 拿出了Gif的第一帧图片
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        animatedImage = [UIImage imageWithCGImage:image scale:UIScreen.mainScreen.scale orientation:UIImageOrientationUp];
    }
    return animatedImage;
}

//关于GIF图片帧时长
+ (float)ssz_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
        
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See and
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    
    return frameDuration;
}

@end

@implementation UITableView (CocoaDebug)
- (void)tableViewScrollToBottomAnimated:(BOOL)animated; {
    NSInteger numberOfSections = self.numberOfSections;
    if (numberOfSections == 0) return;
    NSInteger numberOfRows = [self numberOfRowsInSection:numberOfSections-1];
    if (numberOfRows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:numberOfSections-1];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
- (void)tableViewScrollToHeaderAnimated:(BOOL)animated; {
    NSInteger numberOfSections = self.numberOfSections;
    if (numberOfSections == 0) return;
    NSInteger numberOfRows = [self numberOfRowsInSection:0];
    if (numberOfRows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}
@end

@implementation NSURLSessionTask (CocoaDebug)

- (NSString *)cocoadebugUID {
    id _uniqueIdentifier = [self valueForKeyPath:@"_uniqueIdentifier"];
    if (_uniqueIdentifier) {
        if ([_uniqueIdentifier isKindOfClass:NSUUID.class]) {
            _uniqueIdentifier = [(NSUUID *)_uniqueIdentifier UUIDString];
        } else if ([_uniqueIdentifier isKindOfClass:NSString.class]) {
            
        } else {
            _uniqueIdentifier = nil;
        }
    }
    if (!_uniqueIdentifier) {
        _uniqueIdentifier = objc_getAssociatedObject(self, _cmd);
        if (!_uniqueIdentifier) {
            _uniqueIdentifier = NSUUID.UUID.UUIDString;
            objc_setAssociatedObject(self, _cmd, _uniqueIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return _uniqueIdentifier;
}

@end
