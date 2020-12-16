//
//  AppInfoTableViewCell.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/8.
//

#import <UIKit/UIKit.h>

@class AppInfoModel;
@interface AppInfoTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *leftImageView;
@property (weak, nonatomic, readonly) UILabel *leftLable;
@property (weak, nonatomic, readonly) UILabel *rightLable;

@property (weak, nonatomic) AppInfoModel *model;

@end
