//
//  CrashDetailViewController.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import <UIKit/UIKit.h>

@class _CrashModel;
@interface CrashDetailViewController : UITableViewController

@property (weak, nonatomic) _CrashModel *crashModel;

@end
