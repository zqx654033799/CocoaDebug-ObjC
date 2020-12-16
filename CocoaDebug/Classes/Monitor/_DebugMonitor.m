//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DebugMonitor.h"
#import "_WeakTimer.h"

static const char *CocoaDebugTimerQueueContext = "CocoaDebugTimerQueueContext";

@interface _DebugMonitor ()

@property (nonatomic, strong) _WeakTimer *backgroundTimer;
@property (nonatomic, strong) dispatch_queue_t privateQueue;

@end

@implementation _DebugMonitor

+ (instancetype)sharedInstance {
    return nil;
}

#pragma mark - public
- (void)startMonitoring {
    self.privateQueue = dispatch_queue_create("com.cocoadebug.private_queue", DISPATCH_QUEUE_CONCURRENT);

    self.backgroundTimer = [_WeakTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(updateValue)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:self.privateQueue];

    dispatch_queue_set_specific(self.privateQueue, (__bridge const void *)(self), (void *)CocoaDebugTimerQueueContext, NULL);
}

- (void)stopMonitoring {
    [_backgroundTimer invalidate];
}

#pragma mark - private
- (float)getValue {
    return 0.0;
}

#pragma mark - target action
- (void)updateValue {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.valueBlock) {
            weakSelf.valueBlock([weakSelf getValue]);
        }
    });
}

#pragma mark - dealloc
- (void)dealloc {
    [_backgroundTimer invalidate];
}

@end
