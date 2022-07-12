//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogModel.h"

static NSInteger const _MAXSize = 512;

@implementation _OCLogModel

+ (NSString *)pathAppendingComponent:(NSString *)str
{
    NSString *logPath = cocoadebug_workDirectory(@"Log");
    return [logPath stringByAppendingPathComponent:str];
}

- (instancetype)initWithContent:(NSString *)content fileInfo:(NSString *)fileInfo
{
    if (self = [super init]) {

        self.Id = [[NSUUID UUID] UUIDString];
        self.fileInfo = fileInfo;
        self.date = [NSDate date];
        
        NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData.length > _MAXSize) {
            self.logFilePath = [self.class pathAppendingComponent:[NSString stringWithFormat:@"%@.log", _Id]];
            __weak typeof(self) weakSelf = self;
            cocoadebug_async_run_queue(^{
                if (!weakSelf) return;
                [contentData writeToFile:weakSelf.logFilePath atomically:NO];
            });

            content = [contentData fetchStringWithByteLength:_MAXSize];
            self.content = [content stringByAppendingString:@"..."];
        } else {
            self.content = content;
        }
    }
    
    return self;
}

- (void)dealloc
{
    if (!self.logFilePath) {
        return;
    }
    NSString *logPath = self.logFilePath;
    cocoadebug_async_run_queue(^{
        [NSFileManager.defaultManager removeItemAtPath:logPath error:nil];
    });
}
@end
