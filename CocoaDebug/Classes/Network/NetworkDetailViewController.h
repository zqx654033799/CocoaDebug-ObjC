//
//  NetworkDetailViewController.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import <UIKit/UIKit.h>

@class _HttpModel;
@interface NetworkDetailViewController : UITableViewController

@property (weak, nonatomic) _HttpModel *httpModel;

@end
