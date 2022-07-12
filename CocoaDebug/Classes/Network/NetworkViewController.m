//
//  NetworkViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/7.
//

#import "NetworkViewController.h"
#import "NetworkTableViewCell.h"
#import "_HttpDatasource.h"
#import "NetworkDetailViewController.h"
#import "CocoaDebugBackBarButtonItem.h"

static NSString * const _CellReuseIdentifier = @"_NetworkTableViewCellReuseIdentifier";

@interface NetworkViewController ()<UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation NetworkViewController {
    NSMutableArray *_httpModels;
    
    BOOL _reachEnd;
}

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
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.backBarButtonItem = [CocoaDebugBackBarButtonItem backBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tapTrashButton:)],
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_down" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(didTapDown:)]];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
#ifdef __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        // iOS15 导航栏和表格视图之间 的空隙
        self.tableView.sectionHeaderTopPadding = 0.0f;
    }
#endif
    
    [self.tableView registerClass:NetworkTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:searchBar];
    searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
    if (@available(iOS 13.0, *)) {
        searchBar.searchTextField.backgroundColor = UIColor.whiteColor;
        searchBar.searchTextField.leftViewMode = UITextFieldViewModeNever;
        searchBar.searchTextField.leftView = nil;
        searchBar.searchTextField.returnKeyType = UIReturnKeyDefault;
    } else {
        UITextField *searchField = [searchBar valueForKey:@"_searchField"];
        searchField.backgroundColor = UIColor.whiteColor;
        searchField.leftViewMode = UITextFieldViewModeNever;
        searchField.leftView = nil;
        searchField.returnKeyType = UIReturnKeyDefault;
    }
    searchBar.enablesReturnKeyAutomatically = NO;
    searchBar.barTintColor = UIColor.blackColor;
    searchBar.delegate = self;
    
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
    
    _searchBar = searchBar;
    
    _reachEnd = YES;
    _httpModels = _HttpDatasource.shared.httpModels.mutableCopy;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpModelsChanged) name:HttpModelsChangedNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView tableViewScrollToBottomAnimated:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *close = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[close, [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_up" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(didTapUp:)]];
}

- (void)httpModelsChanged {
    @synchronized (self) {
        NSArray *httpModelsArray = _HttpDatasource.shared.httpModels;
        if (httpModelsArray.count == 0) {
            [_httpModels removeAllObjects];
            [self.tableView reloadData];
            return;
        }
        if (self.searchBar.text.length > 0) {
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
            return;
        }
        _httpModels = httpModelsArray.mutableCopy;
        [self.tableView reloadData];
        if (_reachEnd) {
            [self.tableView tableViewScrollToBottomAnimated:YES];
        }
    }
}

- (void)didTapUp:(id)sender {
    [self.view endEditing:YES];
    [self.tableView tableViewScrollToHeaderAnimated:YES];
    _reachEnd = NO;
}
- (void)didTapDown:(id)sender {
    [self.view endEditing:YES];
    [self.tableView tableViewScrollToBottomAnimated:YES];
    _reachEnd = NO;
}
- (void)tapTrashButton:(id)sender {
    [self.view endEditing:YES];
    [_HttpDatasource.shared reset];
}
#pragma mark - uisearch delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
     NSMutableArray *httpModels = _HttpDatasource.shared.httpModels;
     if (searchText.length == 0) {
         _httpModels = httpModels.mutableCopy;
     } else {
         NSMutableArray *defaultSearchModels = [NSMutableArray arrayWithCapacity:0];
         [httpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger idx, BOOL *stop) {
             if ([obj.url.absoluteString.lowercaseString containsString:searchText.lowercaseString]) {
                 [defaultSearchModels addObject:obj];
             }
         }];
         _httpModels = defaultSearchModels;
     }
     [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _reachEnd = NO;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.searchBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.navigationItem.title = [NSString stringWithFormat:@"[%zd]", _httpModels.count];
    return _httpModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    cell.contentView.userInteractionEnabled = NO;
    cell.model = _httpModels[indexPath.row];
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    _HttpModel *model = _httpModels[indexPath.row];
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
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        __strong typeof(self) strongSelf = weakSelf;
        _HttpModel *model = strongSelf->_httpModels[indexPath.row];
        [_HttpDatasource.shared remove:model];
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NetworkDetailViewController *ndvc = [NetworkDetailViewController new];
    ndvc.httpModel = _httpModels[indexPath.row];
    [self.navigationController pushViewController:ndvc animated:YES];
}
@end
