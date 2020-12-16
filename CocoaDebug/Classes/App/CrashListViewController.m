//
//  CrashListViewController.m
//  Pods
//
//  Created by iPaperman on 2020/12/15.
//

#import "CrashListViewController.h"
#import "CrashTableViewCell.h"
#import "_CrashModel.h"
#import "NSObject+CocoaDebug.h"
#import "_CrashStoreManager.h"
#import "CrashDetailViewController.h"

static NSString * const _CellReuseIdentifier = @"_CrashListTableViewCellReuseIdentifier";

@interface CrashListViewController ()
@property (strong, nonatomic) NSArray<_CrashModel *> *dataSource;
@end

@implementation CrashListViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Crash";
    self.view.backgroundColor = UIColor.blackColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tapTrashButton:)];
    
    self.tableView.separatorColor = [UIColor colorFromHexString:@"#4D4D4D"];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON)];
    [self.tableView registerClass:CrashTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
    
    self.dataSource = _CrashStoreManager.shared.crashArray;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(crashArrayChanged) name:CrashArrayChangedNotification object:nil];
}

- (void)crashArrayChanged {
    self.dataSource = _CrashStoreManager.shared.crashArray;
    [self.tableView reloadData];
}

- (void)tapTrashButton:(id)sender {
    [_CrashStoreManager.shared reset];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CrashTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    cell.contentView.userInteractionEnabled = NO;
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        __strong typeof(self) strongSelf = weakSelf;
        _CrashModel *model = strongSelf.dataSource[indexPath.row];
        [_CrashStoreManager.shared removeCrash:model];
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CrashDetailViewController *cdvc = [CrashDetailViewController new];
    cdvc.crashModel = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:cdvc animated:YES];
}
@end
