//
//  CrashHelper.m
//  Pods
//
//  Created by iPaperman on 2020/12/15.
//

#import "_CrashHelper.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "_CrashStoreManager.h"

#include <sys/socket.h>


static void exceptionHandler(NSException *exception)
{
    if (!_CrashHelper.shared.enable) {
        return;
    }
    _CrashModel *model = [[_CrashModel alloc] initWithName:exception.name reason:exception.reason];
    model.callStacks = exception.callStackSymbols;
    [_CrashStoreManager.shared addCrash:model];
}

static void handleSignal(int signal)
{
    if (!_CrashHelper.shared.enable) {
        return;
    }
    _CrashModel *model = nil;
    switch (signal) {
        case SIGILL:
            model = [[_CrashModel alloc] initWithName:@"SIGILL" reason:@"signal"];
            break;
        case SIGABRT:
            model = [[_CrashModel alloc] initWithName:@"SIGABRT" reason:@"signal"];
            break;
        case SIGFPE:
            model = [[_CrashModel alloc] initWithName:@"SIGFPE" reason:@"signal"];
            break;
        case SIGBUS:
            model = [[_CrashModel alloc] initWithName:@"SIGBUS" reason:@"signal"];
            break;
        case SIGSEGV:
            model = [[_CrashModel alloc] initWithName:@"SIGSEGV" reason:@"signal"];
            break;
        case SIGSYS:
            model = [[_CrashModel alloc] initWithName:@"SIGSYS" reason:@"signal"];
            break;
        case SIGPIPE:
            model = [[_CrashModel alloc] initWithName:@"SIGPIPE" reason:@"signal"];
            break;
        case SIGTRAP:
            model = [[_CrashModel alloc] initWithName:@"SIGTRAP" reason:@"signal"];
            break;
        default:
            return;
    }
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    NSMutableArray<NSString *> *callStacks = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [callStacks addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    model.callStacks = callStacks.copy;
    [_CrashStoreManager.shared addCrash:model];
}

@implementation _CrashHelper {
    BOOL hasBeenRegistered;
}

+ (instancetype)shared
{
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (enable) {
        [self _crash_register];
    } else {
        [self _crash_unregister];
    }
}

- (void)_crash_register {
    if (!hasBeenRegistered) {
        hasBeenRegistered = YES;
        NSSetUncaughtExceptionHandler(exceptionHandler);
        signal(SIGILL, handleSignal);
        signal(SIGABRT, handleSignal);
        signal(SIGFPE, handleSignal);
        signal(SIGBUS, handleSignal);
        signal(SIGSEGV, handleSignal);
        signal(SIGSYS, handleSignal);
        signal(SIGPIPE, handleSignal);
        signal(SIGTRAP, handleSignal);
    }
}

- (void)_crash_unregister {
    if (!hasBeenRegistered) {
        hasBeenRegistered = YES;
        NSSetUncaughtExceptionHandler(nil);
        signal(SIGILL, SIG_DFL);
        signal(SIGABRT, SIG_DFL);
        signal(SIGFPE, SIG_DFL);
        signal(SIGBUS, SIG_DFL);
        signal(SIGSEGV, SIG_DFL);
        signal(SIGSYS, SIG_DFL);
        signal(SIGPIPE, SIG_DFL);
        signal(SIGTRAP, SIG_DFL);
    }
}
@end
