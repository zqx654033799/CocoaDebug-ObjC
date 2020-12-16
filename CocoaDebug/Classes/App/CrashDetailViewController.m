//
//  CrashDetailViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import "CrashDetailViewController.h"
#import "CrashTableViewCell.h"
#import "_CrashModel.h"
#import "CustomTextView.h"
#import "NSObject+CocoaDebug.h"

static NSString * const _CellReuseIdentifier = @"_CrashDetailTableViewCellReuseIdentifier";

@interface CrashDetailCell : UITableViewCell
@property (weak, nonatomic, readonly) UITextView *textContent;
@property (weak, nonatomic, readonly) NSLayoutConstraint *contentH;
@end

@implementation CrashDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UITextView *textContent = [[CustomTextView alloc] initWithFrame:CGRectZero];
        textContent.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:textContent];
        
        id viewDict = NSDictionaryOfVariableBindings(textContent);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[textContent]-(15)-|" options:0 metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[textContent]-(10)-|" options:0 metrics:nil views:viewDict]];
        NSLayoutConstraint *contentH = [NSLayoutConstraint constraintWithItem:textContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.contentView addConstraint:contentH];
        _contentH = contentH;
        _textContent = textContent;
    }
    return self;
}
@end

@interface CrashDetailViewController ()
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *dataSource;
@end

@implementation CrashDetailViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Crash Detail";
    self.view.backgroundColor = UIColor.blackColor;
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor colorFromHexString:@"#4D4D4D"];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DBL_EPSILON, DBL_EPSILON)];
    [self.tableView registerClass:CrashTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
    
    [self setupModels];
}

- (void)setupModels {
    NSMutableString *contentStack = [NSMutableString string];
    [self.crashModel.callStacks enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [contentStack appendFormat:obj.length>0?@"%@\n":@"%@", obj];
    }];
    self.dataSource = @[@{@"Exception Name": self.crashModel.name?:@"N/A"},
                        @{@"Exception Reason": self.crashModel.reason?:@"N/A"},
                        @{@"Exception Stack": contentStack}];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section].allKeys.firstObject;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CrashDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == 2) {
        cell.textContent.font = [UIFont boldSystemFontOfSize:8];
        cell.contentView.backgroundColor = [UIColor colorFromHexString:@"#151515"];
    } else {
        cell.textContent.font = [UIFont boldSystemFontOfSize:14];
        cell.contentView.backgroundColor = UIColor.clearColor;
    }
    cell.textContent.text = self.dataSource[indexPath.section].allValues.firstObject;
    CGSize size = [cell.textContent sizeThatFits:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds)-30, CGFLOAT_MAX)];
    cell.contentH.constant = size.height;
    return cell;
}
@end
