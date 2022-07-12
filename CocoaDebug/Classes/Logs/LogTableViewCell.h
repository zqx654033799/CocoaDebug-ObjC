//
//  LogTableViewCell.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/9.
//

#import <UIKit/UIKit.h>

@class _OCLogModel;
@interface LogTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *labelTitle;
@property (weak, nonatomic, readonly) UILabel *labelContent;

@property (weak, nonatomic) _OCLogModel *model;

@end
