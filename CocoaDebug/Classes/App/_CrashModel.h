//
//  _CrashModel.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import <Foundation/Foundation.h>

@interface _CrashModel : NSObject

@property (copy, nonatomic) NSString *mId;
@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSArray *callStacks;

- (instancetype)initWithName:(NSString *)name reason:(NSString *)reason;

@end
