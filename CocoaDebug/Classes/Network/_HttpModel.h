//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RequestSerializer) {
    RequestSerializerJSON = 0,  //JSON格式
    RequestSerializerForm       //Form格式
};

@interface _HttpModel : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task;

- (void)setRequest:(NSURLRequest *)request;
- (void)setDownloadURL:(NSURL *)downloadURL;
- (void)setResponse:(NSHTTPURLResponse *)response body:(NSData *)body error:(NSError *)error;
@property (nonatomic,copy,readonly)NSString  *logFilePath;

@property (nonatomic, copy, readonly)NSString*taskID;

@property (nonatomic,strong)NSURL   *url;
@property (nonatomic,copy)NSString  *method;

@property (nonatomic,copy)NSData    *requestData;
@property (nonatomic,copy)NSData    *responseData;

@property (nonatomic,copy)NSString  *statusCode;
@property (nonatomic,copy)NSString  *mineType;

@property (nonatomic,copy)NSString  *startTime;
@property (nonatomic,copy)NSString  *endTime;
@property (nonatomic,copy)NSString  *totalDuration;

@property (nonatomic,assign)BOOL    isImage;
@property (nonatomic,copy, readonly)NSString  *downloadFilePath;

@property (nonatomic,copy)NSDate  *domainStartDate  API_AVAILABLE(ios(10.0));
@property (nonatomic,copy)NSDate  *domainEndDate  API_AVAILABLE(ios(10.0));

@property (nonatomic,copy)NSDate  *secureStartDate  API_AVAILABLE(ios(10.0));
@property (nonatomic,copy)NSDate  *secureEndDate  API_AVAILABLE(ios(10.0));

@property (nonatomic,copy)NSDate  *requestStartDate  API_AVAILABLE(ios(10.0));
@property (nonatomic,copy)NSDate  *requestEndDate  API_AVAILABLE(ios(10.0));

@property (nonatomic,copy)NSDate  *responseStartDate  API_AVAILABLE(ios(10.0));
@property (nonatomic,copy)NSDate  *responseEndDate  API_AVAILABLE(ios(10.0));

@property (nonatomic,copy)NSDictionary<NSString*, id>           *requestHeaderFields;
@property (nonatomic,copy)NSDictionary<NSString*, id>           *responseHeaderFields;
@property (nonatomic,assign)BOOL                                isTag;
@property (nonatomic,assign)BOOL                                isSelected;
@property (nonatomic,assign)RequestSerializer                   requestSerializer;//默认JSON格式
@property (nonatomic,copy)NSString                              *errorDescription;
@property (nonatomic,copy)NSString                              *errorLocalizedDescription;
@property (nonatomic,copy)NSString                              *size;

@property (nonatomic,copy)NSError *error;

@end
