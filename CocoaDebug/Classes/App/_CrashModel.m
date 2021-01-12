//
//  _CrashModel.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import "_CrashModel.h"

@implementation _CrashModel
- (instancetype)initWithName:(NSString *)name reason:(NSString *)reason
{
    self = [super init];
    if (self) {
        _mId = NSUUID.UUID.UUIDString;
        _date = NSDate.date;
        _name = name;
        _reason = reason;
        NSString *sv = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *v = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        _version = [NSString stringWithFormat:@"v%@.%@", sv, v];
        _callStacks = NSThread.callStackSymbols;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _mId = [coder decodeObjectForKey:@"mId"];
        _date = [coder decodeObjectForKey:@"date"];
        _name = [coder decodeObjectForKey:@"name"];
        _reason = [coder decodeObjectForKey:@"reason"];
        _callStacks = [coder decodeObjectForKey:@"callStacks"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_mId forKey:@"mId"];
    [coder encodeObject:_date forKey:@"date"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_reason forKey:@"reason"];
    [coder encodeObject:_callStacks forKey:@"callStacks"];
}
@end
