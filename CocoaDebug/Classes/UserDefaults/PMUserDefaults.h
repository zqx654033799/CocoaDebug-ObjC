//
//  PMUserDefaults.h
//  Pods
//
//  Created by iPaperman on 2020/12/4.
//

#import <Foundation/Foundation.h>

@interface PMUserDefaults : NSObject

@property (strong, nonatomic, class, readonly) PMUserDefaults *standardUserDefaults;

- (void)setData:(NSData *)value forKey:(NSString *)defaultName;
- (void)setString:(NSString *)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

- (NSData *)dataForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;

- (BOOL)synchronize;

@end
