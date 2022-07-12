//
//  LogViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/7.
//

#import "LogViewController.h"
#import "LogTableViewCell.h"
#import "_OCLogStoreManager.h"

static NSString * const _CellReuseIdentifier = @"_LogTableViewCellReuseIdentifier";

@interface LogViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) UITableView *defaultTableView;
@property (weak, nonatomic) UITableView *h5TableView;

@property (strong, nonatomic) UISearchBar *defaultSearchBar;
@property (strong, nonatomic) UISearchBar *h5SearchBar;
@end

@implementation LogViewController {
    NSMutableArray *_defaultLogArray;
    NSMutableArray *_h5LogArray;
    
    BOOL _reachEndDefault;
    BOOL _reachEndH5;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetLogs:)], [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_down" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(didTapDown:)]];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Log",@"Web"]];
    if (UIScreen.mainScreen.bounds.size.width <= 330) {
        [segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11]} forState:UIControlStateNormal];
    } else {
        [segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    }
    [segmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;

    UITableView *defaultTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    UITableView *h5TableView = [[UITableView alloc] initWithFrame:CGRectZero];
    
    for (UITableView *tableView in @[h5TableView,defaultTableView]) {
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:tableView];
        
        tableView.allowsSelection = NO;
        tableView.estimatedRowHeight = 44;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = UIColor.blackColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = UIColor.blackColor;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [tableView registerClass:LogTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
#ifdef __IPHONE_15_0
        if (@available(iOS 15.0, *)) {
            // iOS15 导航栏和表格视图之间 的空隙
            tableView.sectionHeaderTopPadding = 0.0f;
        }
#endif
    }
    id viewsDict = NSDictionaryOfVariableBindings(defaultTableView,h5TableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[defaultTableView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[defaultTableView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[h5TableView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[h5TableView]|" options:0 metrics:nil views:viewsDict]];
    
    UISearchBar *defaultSearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    UISearchBar *h5SearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    
    for (UISearchBar *searchBar in @[defaultSearchBar,h5SearchBar]) {
        [self.view addSubview:searchBar];
        searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
        if (@available(iOS 13.0, *)) {
            searchBar.searchTextField.backgroundColor = UIColor.whiteColor;
            searchBar.searchTextField.leftViewMode = UITextFieldViewModeNever;
            searchBar.searchTextField.leftView = nil;
        } else {
            UITextField *searchField = [searchBar valueForKey:@"_searchField"];
            searchField.backgroundColor = UIColor.whiteColor;
            searchField.leftViewMode = UITextFieldViewModeNever;
            searchField.leftView = nil;
        }
        searchBar.enablesReturnKeyAutomatically = NO;
        searchBar.barTintColor = UIColor.blackColor;
        searchBar.delegate = self;
    }
    
    _defaultSearchBar = defaultSearchBar;
    _h5SearchBar = h5SearchBar;
    
    _defaultTableView = defaultTableView;
    _h5TableView = h5TableView;
    
    _defaultLogArray = _OCLogStoreManager.shared.defaultLogArray.mutableCopy;
    _h5LogArray = _OCLogStoreManager.shared.h5LogArray.mutableCopy;
    
    _reachEndDefault = YES;
    _reachEndH5 = YES;
    
    segmentedControl.selectedSegmentIndex = CocoaDebugSettings.shared.logSelectIndex;
    [self segmentedChanged:segmentedControl];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(defaultLogChanged) name:LogDefaultChangedNotification object:nil];
    [nc addObserver:self selector:@selector(h5LogChanged) name:LogH5ChangedNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.defaultTableView tableViewScrollToBottomAnimated:NO];
        [self.h5TableView tableViewScrollToBottomAnimated:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *close = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[close, [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_up" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(didTapUp:)]];
}

- (void)defaultLogChanged {
    @synchronized (self) {
        if (self.defaultSearchBar.text.length > 0) {
            [self searchBar:self.defaultSearchBar textDidChange:self.defaultSearchBar.text];
            return;
        }
        _defaultLogArray = _OCLogStoreManager.shared.defaultLogArray.mutableCopy;
        [_defaultTableView reloadData];
        if (_reachEndDefault) {
            [_defaultTableView tableViewScrollToBottomAnimated:YES];
        }
    }
}

- (void)h5LogChanged {
    @synchronized (self) {
        if (self.h5SearchBar.text.length > 0) {
            [self searchBar:self.h5SearchBar textDidChange:self.h5SearchBar.text];
            return;
        }
        _h5LogArray = _OCLogStoreManager.shared.h5LogArray.mutableCopy;
        [_h5TableView reloadData];
        if (_reachEndH5) {
            [_h5TableView tableViewScrollToBottomAnimated:YES];
        }
    }
}

- (void)segmentedChanged:(UISegmentedControl *)sender {
    [self.view endEditing:YES];
    CocoaDebugSettings.shared.logSelectIndex = sender.selectedSegmentIndex;
    switch (sender.selectedSegmentIndex) {
        case 0: {
            [self.view addSubview:self.defaultTableView];
        }   break;
        case 1: {
            [self.view addSubview:self.h5TableView];
        }   break;
        default:
            break;
    }
}
- (void)didTapUp:(id)sender {
    [self.view endEditing:YES];
    switch (CocoaDebugSettings.shared.logSelectIndex) {
        case 0: {
            [self.defaultTableView tableViewScrollToHeaderAnimated:YES];
            _reachEndDefault = NO;
        }   break;
        case 1: {
            [self.h5TableView tableViewScrollToHeaderAnimated:YES];
            _reachEndH5 = NO;
        }   break;
        default:
            break;
    }
}
- (void)didTapDown:(id)sender {
    [self.view endEditing:YES];
    switch (CocoaDebugSettings.shared.logSelectIndex) {
        case 0: {
            [self.defaultTableView tableViewScrollToBottomAnimated:YES];
            _reachEndDefault = YES;
        }   break;
        case 1: {
            [self.h5TableView tableViewScrollToBottomAnimated:YES];
            _reachEndH5 = YES;
        }   break;
        default:
            break;
    }
}
- (void)resetLogs:(id)sender {
    [self.view endEditing:YES];
    switch (CocoaDebugSettings.shared.logSelectIndex) {
        case 0: {
            [_OCLogStoreManager.shared resetDefaultLogs];
        }   break;
        case 1: {
            [_OCLogStoreManager.shared resetH5Logs];
        }   break;
        default:
            break;
    }
}

#pragma - mark : UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchBar isEqual:self.defaultSearchBar]) {
        NSMutableArray *defaultLogArray = _OCLogStoreManager.shared.defaultLogArray;
        if (searchText.length == 0) {
            _defaultLogArray = defaultLogArray.mutableCopy;
        } else {
            NSMutableArray *defaultSearchModels = [NSMutableArray arrayWithCapacity:0];
            [defaultLogArray enumerateObjectsUsingBlock:^(_OCLogModel *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.content.lowercaseString containsString:searchText.lowercaseString]) {
                    [defaultSearchModels addObject:obj];
                }
            }];
            _defaultLogArray = defaultSearchModels;
        }
        [self.defaultTableView reloadData];
    }
    else if ([searchBar isEqual:self.h5SearchBar]) {
        NSMutableArray *h5LogArray = _OCLogStoreManager.shared.h5LogArray;
        if (searchText.length == 0) {
            _h5LogArray = h5LogArray.mutableCopy;
        } else {
            NSMutableArray *h5SearchModels = [NSMutableArray arrayWithCapacity:0];
            [h5LogArray enumerateObjectsUsingBlock:^(_OCLogModel *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.content.lowercaseString containsString:searchText.lowercaseString]) {
                    [h5SearchModels addObject:obj];
                }
            }];
            _h5LogArray = h5SearchModels;
        }
        [self.h5TableView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.defaultTableView]) {
        _reachEndDefault = NO;
    }
    else if ([scrollView isEqual:self.h5TableView]) {
        _reachEndH5 = NO;
    }
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.defaultTableView]) {
        return self.defaultSearchBar;
    }
    if ([tableView isEqual:self.h5TableView]) {
        return self.h5SearchBar;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id content = cell.model.content;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    if (!cell.model.logFilePath) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentLeft;
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: [UIFont systemFontOfSize:13]}];
        [alertController setValue:attributedMessage forKey:@"attributedMessage"];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拷贝" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard.generalPasteboard.string = content;
        }]];
    } else {
        content = [NSURL fileURLWithPath:cell.model.logFilePath];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"共享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[content] applicationActivities:nil];
        [weakSelf presentViewController:activityController animated:YES completion:NULL];
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.defaultTableView]) {
        return _defaultLogArray.count;
    }
    if ([tableView isEqual:self.h5TableView]) {
        return _h5LogArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    if ([tableView isEqual:self.defaultTableView]) {
        cell.model = _defaultLogArray[indexPath.row];
    }
    else if ([tableView isEqual:self.h5TableView]) {
        cell.model = _h5LogArray[indexPath.row];
    }
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __block _OCLogModel *model = nil;
    if ([tableView isEqual:self.defaultTableView]) {
        model = _defaultLogArray[indexPath.row];
    }
    else if ([tableView isEqual:self.h5TableView]) {
        model = _h5LogArray[indexPath.row];
    }
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:model.isTag?@"UnTag":@"Tag" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        model.isTag = !model.isTag;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        completionHandler(YES);
    }];
    action.backgroundColor = [@"#007aff" hexColor];
    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    UIContextualActionHandler handler = NULL;
    if ([tableView isEqual:self.defaultTableView]) {
        handler = ^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
            __strong typeof(self) strongSelf = weakSelf;
            _OCLogModel *model = strongSelf->_defaultLogArray[indexPath.row];
            [_OCLogStoreManager.shared removeLog:model];
            completionHandler(YES);
        };
    }
    else if ([tableView isEqual:self.h5TableView]) {
        handler = ^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
            __strong typeof(self) strongSelf = weakSelf;
            _OCLogModel *model = strongSelf->_h5LogArray[indexPath.row];
            [_OCLogStoreManager.shared removeLog:model];
            completionHandler(YES);
        };
    }
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:handler];
    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}
@end
