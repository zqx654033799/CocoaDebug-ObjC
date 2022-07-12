//
//  AppInfoViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/7.
//

#import "AppInfoViewController.h"
#import "AppInfoTableViewCell.h"
#import "AppInfoModel.h"
#import "CrashListViewController.h"
#import "_CrashStoreManager.h"
#import "CocoaDebugBackBarButtonItem.h"

static NSString * const _CellReuseIdentifier = @"_AppInfoTableViewCellReuseIdentifier";

@interface AppInfoViewController ()
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSArray<AppInfoModel *> *> *> *dataSource;
@end

@implementation AppInfoViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
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
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.backBarButtonItem = [CocoaDebugBackBarButtonItem backBarButtonItem];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.separatorColor = [UIColor colorFromHexString:@"#4D4D4D"];
    [self.tableView registerClass:AppInfoTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
#ifdef __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        // iOS15 导航栏和表格视图之间 的空隙
        self.tableView.sectionHeaderTopPadding = 0.0f;
    }
#endif
    
    self.dataSource = [AppInfoModel infos];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(crashArrayChanged) name:CrashArrayChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert) name:AppInfoChangedNeedRestartNotification object:nil];
}

- (void)crashArrayChanged {
    self.dataSource = [AppInfoModel infos];
    [self.tableView reloadData];
}

- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"You must restart APP to ensure the changes take effect" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Restart now" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        exit(0);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].allValues.firstObject.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section].allKeys.firstObject;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = UIColor.darkGrayColor;
    header.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.section].allValues.firstObject[indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0 && cell.rightLable.text.intValue > 0) {
        cell.rightLable.textColor = UIColor.redColor;
    } else {
        cell.rightLable.textColor = UIColor.whiteColor;
    }
    [cell layoutIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIViewController *clvc = [CrashListViewController new];
        [self.navigationController pushViewController:clvc animated:YES];
    }
    else if (indexPath.section == 1) {
        AppInfoModel *model = self.dataSource[indexPath.section].allValues.firstObject[indexPath.row];
        if (indexPath.section == 2) {
            UIPasteboard.generalPasteboard.string = model.rightString;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"copied bundle name to clipboard" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
        else if (indexPath.section == 3) {
            UIPasteboard.generalPasteboard.string = model.rightString;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"copied bundle id to clipboard" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    }
}
@end
