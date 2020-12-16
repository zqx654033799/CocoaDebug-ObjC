//
//  CrashTableViewCell.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import <UIKit/UIKit.h>

@class _CrashModel;
@interface CrashTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *labelTitle;
@property (weak, nonatomic, readonly) UITextView *textContent;

@property (weak, nonatomic) _CrashModel *model;

@end
