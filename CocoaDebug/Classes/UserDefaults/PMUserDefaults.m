//
//  PMUserDefaults.m
//  Pods
//
//  Created by iPaperman on 2020/12/4.
//

#import "PMUserDefaults.h"

@interface PMUserDefaults () {
    NSMutableDictionary *_map;
    BOOL _changed;
}
@end

@implementation PMUserDefaults
+ (PMUserDefaults *)standardUserDefaults
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)_mapPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.paperman.cocoadebug.plist"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.class._mapPath]) {
            _map = [NSMutableDictionary dictionaryWithContentsOfFile:self.class._mapPath];
        } else {
            _map = [NSMutableDictionary dictionary];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
        [nc addObserver:self selector:@selector(_appDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName;
{
    if (value && defaultName) {
        [_map setValue:value forKey:defaultName];
        _changed = YES;
    }
}
- (void)setData:(NSData *)value forKey:(NSString *)defaultName;
{
    id v = value;
    [self setObject:v forKey:defaultName];
}
- (void)setString:(NSString *)value forKey:(NSString *)defaultName;
{
    id v = value;
    [self setObject:v forKey:defaultName];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
{
    id v = [NSNumber numberWithInteger:value];
    [self setObject:v forKey:defaultName];
}
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
{
    id v = [NSNumber numberWithFloat:value];
    [self setObject:v forKey:defaultName];
}
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
{
    id v = [NSNumber numberWithDouble:value];
    [self setObject:v forKey:defaultName];
}
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
{
    id v = [NSNumber numberWithBool:value];
    [self setObject:v forKey:defaultName];
}

- (NSObject *)objectForKey:(NSString *)defaultName;
{
    if (defaultName) {
        return [_map valueForKey:defaultName];
    }
    return nil;
}
- (NSData *)dataForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return v;
}
- (NSString *)stringForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return [v stringValue];
}
- (NSInteger)integerForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return [v integerValue];
}
- (float)floatForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return [v floatValue];
}
- (double)doubleForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return [v doubleValue];
}
- (BOOL)boolForKey:(NSString *)defaultName;
{
    id v = [self objectForKey:defaultName];
    return [v boolValue];
}

- (BOOL)synchronize;
{
    if ([_map writeToFile:self.class._mapPath atomically:NO]) {
        _changed = NO;
        return YES;
    }
    return NO;
}

#pragma - mark : Application Notification
- (void)_appWillBeTerminated {
    if (_changed) {
        [_map writeToFile:self.class._mapPath atomically:NO];
    }
}
- (void)_appDidReceiveMemoryWarning {
    [self _appWillBeTerminated];
}
@end
