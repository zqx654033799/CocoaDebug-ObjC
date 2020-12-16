//
//  AppInfoModel.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/8.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSNotificationName const AppInfoChangedNeedRestartNotification;

@interface AppInfoModel : NSObject

+ (NSArray<NSDictionary<NSString *, NSArray<AppInfoModel *> *> *> *)infos;

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *leftString;
@property (copy, nonatomic) NSString *rightString;
@property (strong, nonatomic) UISwitch *accessoryView;

@end
