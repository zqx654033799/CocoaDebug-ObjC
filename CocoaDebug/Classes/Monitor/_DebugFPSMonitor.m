//
//  _DebugFPSMonitor.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/4.
//

#import "_DebugFPSMonitor.h"

@interface _DebugFPSMonitor ()
@property (strong, nonatomic) CADisplayLink *displayLink;

@property (assign, nonatomic) CFAbsoluteTime lastNotificationTime;
@property (assign, nonatomic) NSInteger numberOfFrames;
@end

@implementation _DebugFPSMonitor {
    CGFloat _fps;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFromDisplayLink:)];
        _lastNotificationTime = 0.0;
        _fps = 0.0;
    }
    return self;
}

- (void)startMonitoring {
    [super startMonitoring];
    [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)stopMonitoring {
    [super stopMonitoring];
    [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)updateFromDisplayLink:(CADisplayLink *)displayLink {
    if (self.lastNotificationTime == 0.0) {
        self.lastNotificationTime = CFAbsoluteTimeGetCurrent();
        return;
    }
    
    self.numberOfFrames += 1;
    
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime elapsedTime = currentTime - self.lastNotificationTime;

    NSTimeInterval const notificationDelay = 1.0;
    if (elapsedTime >= notificationDelay) {
        _fps = self.numberOfFrames / elapsedTime;
        self.lastNotificationTime = 0.0;
        self.numberOfFrames = 0;
    }
}

- (float)getValue {
    return _fps;
}

@end
