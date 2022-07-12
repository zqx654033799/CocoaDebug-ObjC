//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, H5LogType) {
    H5LogTypeNone = 0,
    H5LogTypeWK
};

typedef NS_ENUM (NSInteger, CocoaDebugToolType) {
    CocoaDebugToolTypeNone,
    CocoaDebugToolTypeJson,
    CocoaDebugToolTypeProtobuf
};

@interface _OCLogModel : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *fileInfo;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic,copy)NSString  *logFilePath;

@property (nonatomic, assign) BOOL isTag;

@property (nonatomic, assign) H5LogType h5LogType;

- (instancetype)initWithContent:(NSString *)content fileInfo:(NSString *)fileInfo;

@end
