//
//  NetworkTableViewCell.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/10.
//

#import <UIKit/UIKit.h>

@class _HttpModel;
@interface NetworkTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *methodLabel;
@property (weak, nonatomic, readonly) UILabel *statusCodeLabel;
@property (weak, nonatomic, readonly) UILabel *requestTimeLabel;
@property (weak, nonatomic, readonly) UILabel *requestUrlLabel;

@property (weak, nonatomic) _HttpModel *model;

@end
