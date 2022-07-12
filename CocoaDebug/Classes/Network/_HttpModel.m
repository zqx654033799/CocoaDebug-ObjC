//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_HttpModel.h"

static NSInteger const _MAXSize = 512;

@interface _HttpModel ()
@property (nonatomic,strong)NSOperationQueue *operationQueue;
@end

@implementation _HttpModel
+ (NSString *)pathAppendingComponent:(NSString *)str
{
    NSString *networkPath = cocoadebug_workDirectory(@"Network");
    return [networkPath stringByAppendingPathComponent:str];
}

//default value for @property
- (instancetype)initWithTask:(NSURLSessionTask *)task; {
    if (self = [super init])  {
        _taskID = task.cocoadebugUID;

        _logFilePath = [self.class pathAppendingComponent:[NSString stringWithFormat:@"%@.log", _taskID]];

        self.statusCode = @"0";
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)async_run:(dispatch_block_t)block {
    [self.operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

- (void)writeLogWithString:(NSString *)str {
    __weak typeof(self) weakSelf = self;
    [self async_run:^{
        if (!weakSelf) return;
        if (![NSFileManager.defaultManager fileExistsAtPath:weakSelf.logFilePath]) {
            [NSData.data writeToFile:weakSelf.logFilePath atomically:NO];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:weakSelf.logFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }];
}

- (void)writeLogWithData:(NSData *)data {
    __weak typeof(self) weakSelf = self;
    [self async_run:^{
        if (!weakSelf) return;
        if (![NSFileManager.defaultManager fileExistsAtPath:weakSelf.logFilePath]) {
            [NSData.data writeToFile:weakSelf.logFilePath atomically:NO];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:weakSelf.logFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }];
}

- (void)setRequest:(NSURLRequest *)request {
    NSDate *startDate = NSDate.date;
    self.startTime = [NSString stringWithFormat:@"%f", [startDate timeIntervalSince1970]];
    if (request.URL) {
        self.url = request.URL;
        self.method = request.HTTPMethod;
        [self writeLogWithString:[NSString stringWithFormat:@"------- %@ URL -------\n", self.method]];
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.url]];
        
        [self writeLogWithString:@"------- Request Start Time -------\n"];
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", [startDate format]]];
        
        [self writeLogWithString:@"------- Request Header -------\n"];
        self.requestHeaderFields = request.allHTTPHeaderFields;
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.requestHeaderFields.headerToString]];
        
        NSString *contentType = self.requestHeaderFields[@"Content-Type"];
        if (contentType) {
            if ([contentType.lowercaseString containsString:@"json"]) {
                self.requestSerializer = RequestSerializerJSON;
            } else {
                self.requestSerializer = RequestSerializerForm;
            }
        }

        NSData *requestData = nil;
        if (request.HTTPBody) {
            requestData = request.HTTPBody;
        }
        if (request.HTTPBodyStream) {//liman
            requestData = [NSData dataWithInputStream:request.HTTPBodyStream];
        }
        if (requestData) {
            [self writeLogWithString:@"------- Request Size -------\n"];
            [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", [[NSByteCountFormatter alloc] stringFromByteCount:requestData.length]]];

            [self writeLogWithString:@"------- Request Body -------\n"];
            [self setRequestData:requestData];
            [self writeLogWithData:requestData];
        }
    }
}

- (void)setDownloadURL:(NSURL *)downloadURL {
    if (downloadURL) {
        _downloadFilePath = downloadURL.path;
    }
}

- (void)setResponse:(NSHTTPURLResponse *)response body:(NSData *)body error:(NSError *)error {
    NSDate *endDate = NSDate.date;
    NSTimeInterval endTimeDouble = [endDate timeIntervalSince1970];
    NSTimeInterval durationDouble = fabs(endTimeDouble - self.startTime.doubleValue);
    self.endTime = [NSString stringWithFormat:@"%f", endTimeDouble];
    self.totalDuration = [NSString stringWithFormat:@"%f (s)", durationDouble];

    [self writeLogWithString:@"------- Request End Time -------\n"];
    [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", [endDate format]]];
    
    [self writeLogWithString:@"------- Total Time -------\n"];
    [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.totalDuration]];

    if (response) {
        self.mineType = response.MIMEType;

        [self writeLogWithString:@"------- Response Status Code -------\n"];
        self.statusCode = [NSString stringWithFormat:@"%zd", response.statusCode];
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.statusCode]];

        [self writeLogWithString:@"------- Response Header -------\n"];
        self.responseHeaderFields = response.allHeaderFields;
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.responseHeaderFields.headerToString]];

        NSData *responseData = body;
        if (self.downloadFilePath) {
            [self writeLogWithString:@"------- Response Size -------\n"];
            NSNumber *fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:self.downloadFilePath error:nil][NSFileSize];
            self.size = [[NSByteCountFormatter new] stringFromByteCount:fileSize.longValue];
            [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.size]];

            NSString *ext = self.url.absoluteString.pathExtension.lowercaseString;
            if ([@"png" isEqualToString:ext] ||
                [@"jpg" isEqualToString:ext] ||
                [@"jpeg" isEqualToString:ext] ||
                [@"gif" isEqualToString:ext]) {
                self.isImage = YES;
            }
            [self writeLogWithString:@"------- Response File -------\n"];
            [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.downloadFilePath]];
        } else if (responseData) {
            [self writeLogWithString:@"------- Response Size -------\n"];
            self.size = [[NSByteCountFormatter alloc] stringFromByteCount:responseData.length];
            [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.size]];
            
            [self writeLogWithString:@"------- Response Body -------\n"];
            [self setResponseData:responseData];
            [self writeLogWithData:responseData];
        }
    }
    if (error) {
        self.error = error;
        [self writeLogWithString:@"------- Responce Error -------\n"];
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.errorLocalizedDescription]];
        
        [self writeLogWithString:@"------- Responce Error Description -------\n"];
        [self writeLogWithString:[NSString stringWithFormat:@"%@\n\n", self.errorDescription]];
    }
}

- (void)setRequestData:(NSData *)requestData {
    if (requestData) {
        NSData *tmpData = nil;
        if (requestData.length > _MAXSize) {
            NSString *str = [requestData fetchStringWithByteLength:_MAXSize];
            tmpData = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            tmpData = requestData.copy;
        }
        _requestData = tmpData;
    }
}

- (void)setResponseData:(NSData *)responseData {
    if (responseData) {
        NSData *tmpData = nil;
        if (responseData.length > _MAXSize) {
            NSString *str = [responseData fetchStringWithByteLength:_MAXSize];
            tmpData = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            tmpData = responseData.copy;
        }
        _responseData = tmpData;
    }
}

- (void)setError:(NSError *)error {
    _error = error;
    if (!error) {
        //https://httpcodes.co/status/
        switch (self.statusCode.integerValue) {
            case 100:
                self.errorDescription = @"Informational :\nClient should continue with request";
                self.errorLocalizedDescription = @"Continue";
                break;
            case 101:
                self.errorDescription = @"Informational :\nServer is switching protocols";
                self.errorLocalizedDescription = @"Switching Protocols";
                break;
            case 102:
                self.errorDescription = @"Informational :\nServer has received and is processing the request";
                self.errorLocalizedDescription = @"Processing";
                break;
            case 103:
                self.errorDescription = @"Informational :\nresume aborted PUT or POST requests";
                self.errorLocalizedDescription = @"Checkpoint";
                break;
            case 122:
                self.errorDescription = @"Informational :\nURI is longer than a maximum of 2083 characters";
                self.errorLocalizedDescription = @"Request-URI too long";
                break;
            case 300:
                self.errorDescription = @"Redirection :\nMultiple options for the resource delivered";
                self.errorLocalizedDescription = @"Multiple Choices";
                break;
            case 301:
                self.errorDescription = @"Redirection :\nThis and all future requests directed to the given URI";
                self.errorLocalizedDescription = @"Moved Permanently";
                break;
            case 302:
                self.errorDescription = @"Redirection :\nTemporary response to request found via alternative URI";
                self.errorLocalizedDescription = @"Found";
                break;
            case 303:
                self.errorDescription = @"Redirection :\nPermanent response to request found via alternative URI";
                self.errorLocalizedDescription = @"See Other";
                break;
            case 304:
                self.errorDescription = @"Redirection :\nResource has not been modified since last requested";
                self.errorLocalizedDescription = @"Not Modified";
                break;
            case 305:
                self.errorDescription = @"Redirection :\nContent located elsewhere, retrieve from there";
                self.errorLocalizedDescription = @"Use Proxy";
                break;
            case 306:
                self.errorDescription = @"Redirection :\nSubsequent requests should use the specified proxy";
                self.errorLocalizedDescription = @"Switch Proxy";
                break;
            case 307:
                self.errorDescription = @"Redirection :\nConnect again to different URI as provided";
                self.errorLocalizedDescription = @"Temporary Redirect";
                break;
            case 308:
                self.errorDescription = @"Redirection :\nConnect again to a different URI using the same method";
                self.errorLocalizedDescription = @"Permanent Redirect";
                break;
            case 400:
                self.errorDescription = @"Client Error :\nRequest cannot be fulfilled due to bad syntax";
                self.errorLocalizedDescription = @"Bad Request";
                break;
            case 401:
                self.errorDescription = @"Client Error :\nAuthentication is possible but has failed";
                self.errorLocalizedDescription = @"Unauthorized";
                break;
            case 402:
                self.errorDescription = @"Client Error :\nPayment required, reserved for future use";
                self.errorLocalizedDescription = @"Payment Required";
                break;
            case 403:
                self.errorDescription = @"Client Error :\nServer refuses to respond to request";
                self.errorLocalizedDescription = @"Forbidden";
                break;
            case 404:
                self.errorDescription = @"Client Error :\nRequested resource could not be found";
                self.errorLocalizedDescription = @"Not Found";
                break;
            case 405:
                self.errorDescription = @"Client Error :\nRequest method not supported by that resource";
                self.errorLocalizedDescription = @"Method Not Allowed";
                break;
            case 406:
                self.errorDescription = @"Client Error :\nContent not acceptable according to the Accept headers";
                self.errorLocalizedDescription = @"Not Acceptable";
                break;
            case 407:
                self.errorDescription = @"Client Error :\nClient must first authenticate itself with the proxy";
                self.errorLocalizedDescription = @"Proxy Authentication Required";
                break;
            case 408:
                self.errorDescription = @"Client Error :\nServer timed out waiting for the request";
                self.errorLocalizedDescription = @"Request Timeout";
                break;
            case 409:
                self.errorDescription = @"Client Error :\nRequest could not be processed because of conflict";
                self.errorLocalizedDescription = @"Conflict";
                break;
            case 410:
                self.errorDescription = @"Client Error :\nResource is no longer available and will not be available again";
                self.errorLocalizedDescription = @"Gone";
                break;
            case 411:
                self.errorDescription = @"Client Error :\nRequest did not specify the length of its content";
                self.errorLocalizedDescription = @"Length Required";
                break;
            case 412:
                self.errorDescription = @"Client Error :\nServer does not meet request preconditions";
                self.errorLocalizedDescription = @"Precondition Failed";
                break;
            case 413:
                self.errorDescription = @"Client Error :\nRequest is larger than the server is willing or able to process";
                self.errorLocalizedDescription = @"Request Entity Too Large";
                break;
            case 414:
                self.errorDescription = @"Client Error :\nURI provided was too long for the server to process";
                self.errorLocalizedDescription = @"Request-URI Too Long";
                break;
            case 415:
                self.errorDescription = @"Client Error :\nServer does not support media type";
                self.errorLocalizedDescription = @"Unsupported Media Type";
                break;
            case 416:
                self.errorDescription = @"Client Error :\nClient has asked for unprovidable portion of the file";
                self.errorLocalizedDescription = @"Requested Range Not Satisfiable";
                break;
            case 417:
                self.errorDescription = @"Client Error :\nServer cannot meet requirements of Expect request-header field";
                self.errorLocalizedDescription = @"Expectation Failed";
                break;
            case 418:
                self.errorDescription = @"Client Error :\nI'm a teapot";
                self.errorLocalizedDescription = @"I'm a Teapot";
                break;
            case 420:
                self.errorDescription = @"Client Error :\nTwitter rate limiting";
                self.errorLocalizedDescription = @"Enhance Your Calm";
                break;
            case 421:
                self.errorDescription = @"Client Error :\nMisdirected Request";
                self.errorLocalizedDescription = @"Misdirected Request";
                break;
            case 422:
                self.errorDescription = @"Client Error :\nRequest unable to be followed due to semantic errors";
                self.errorLocalizedDescription = @"Unprocessable Entity";
                break;
            case 423:
                self.errorDescription = @"Client Error :\nResource that is being accessed is locked";
                self.errorLocalizedDescription = @"Locked";
                break;
            case 424:
                self.errorDescription = @"Client Error :\nRequest failed due to failure of a previous request";
                self.errorLocalizedDescription = @"Failed Dependency";
                break;
            case 426:
                self.errorDescription = @"Client Error :\nClient should switch to a different protocol";
                self.errorLocalizedDescription = @"Upgrade Required";
                break;
            case 428:
                self.errorDescription = @"Client Error :\nOrigin server requires the request to be conditional";
                self.errorLocalizedDescription = @"Precondition Required";
                break;
            case 429:
                self.errorDescription = @"Client Error :\nUser has sent too many requests in a given amount of time";
                self.errorLocalizedDescription = @"Too Many Requests";
                break;
            case 431:
                self.errorDescription = @"Client Error :\nServer is unwilling to process the request";
                self.errorLocalizedDescription = @"Request Header Fields Too Large";
                break;
            case 444:
                self.errorDescription = @"Client Error :\nServer returns no information and closes the connection";
                self.errorLocalizedDescription = @"No Response";
                break;
            case 449:
                self.errorDescription = @"Client Error :\nRequest should be retried after performing action";
                self.errorLocalizedDescription = @"Retry With";
                break;
            case 450:
                self.errorDescription = @"Client Error :\nWindows Parental Controls blocking access to webpage";
                self.errorLocalizedDescription = @"Blocked by Windows Parental Controls";
                break;
            case 451:
                self.errorDescription = @"Client Error :\nThe server cannot reach the client's mailbox";
                self.errorLocalizedDescription = @"Wrong Exchange server";
                break;
            case 499:
                self.errorDescription = @"Client Error :\nConnection closed by client while HTTP server is processing";
                self.errorLocalizedDescription = @"Client Closed Request";
                break;
            case 500:
                self.errorDescription = @"Server Error :\ngeneric error message";
                self.errorLocalizedDescription = @"Internal Server Error";
                break;
            case 501:
                self.errorDescription = @"Server Error :\nserver does not recognise method or lacks ability to fulfill";
                self.errorLocalizedDescription = @"Not Implemented";
                break;
            case 502:
                self.errorDescription = @"Server Error :\nserver received an invalid response from upstream server";
                self.errorLocalizedDescription = @"Bad Gateway";
                break;
            case 503:
                self.errorDescription = @"Server Error :\nserver is currently unavailable";
                self.errorLocalizedDescription = @"Service Unavailable";
                break;
            case 504:
                self.errorDescription = @"Server Error :\ngateway did not receive response from upstream server";
                self.errorLocalizedDescription = @"Gateway Timeout";
                break;
            case 505:
                self.errorDescription = @"Server Error :\nserver does not support the HTTP protocol version";
                self.errorLocalizedDescription = @"HTTP Version Not Supported";
                break;
            case 506:
                self.errorDescription = @"Server Error :\ncontent negotiation for the request results in a circular reference";
                self.errorLocalizedDescription = @"Variant Also Negotiates";
                break;
            case 507:
                self.errorDescription = @"Server Error :\nserver is unable to store the representation";
                self.errorLocalizedDescription = @"Insufficient Storage";
                break;
            case 508:
                self.errorDescription = @"Server Error :\nserver detected an infinite loop while processing the request";
                self.errorLocalizedDescription = @"Loop Detected";
                break;
            case 509:
                self.errorDescription = @"Server Error :\nbandwidth limit exceeded";
                self.errorLocalizedDescription = @"Bandwidth Limit Exceeded";
                break;
            case 510:
                self.errorDescription = @"Server Error :\nfurther extensions to the request are required";
                self.errorLocalizedDescription = @"Not Extended";
                break;
            case 511:
                self.errorDescription = @"Server Error :\nclient needs to authenticate to gain network access";
                self.errorLocalizedDescription = @"Network Authentication Required";
                break;
            case 526:
                self.errorDescription = @"Server Error :\nThe origin web server does not have a valid SSL certificate";
                self.errorLocalizedDescription = @"Invalid SSL certificate";
                break;
            case 598:
                self.errorDescription = @"Server Error :\nnetwork read timeout behind the proxy";
                self.errorLocalizedDescription = @"Network Read Timeout Error";
                break;
            case 599:
                self.errorDescription = @"Server Error :\nnetwork connect timeout behind the proxy";
                self.errorLocalizedDescription = @"Network Connect Timeout Error";
                break;
            default:
                break;
        }
    } else {
        self.errorDescription = error.description;
        self.errorLocalizedDescription = error.localizedDescription;
    }
}

- (void)dealloc
{
    NSString *logFilePath = self.logFilePath;
    NSString *downloadFilePath = self.downloadFilePath;
    cocoadebug_async_run_queue(^{
        [NSFileManager.defaultManager removeItemAtPath:logFilePath error:nil];
        if (downloadFilePath) {
            [NSFileManager.defaultManager removeItemAtPath:downloadFilePath error:nil];
        }
    });
}
@end
