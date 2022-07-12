//
//  NetworkDetailViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import "NetworkDetailViewController.h"
#import "NetworkDetailTableViewCell.h"
#import "NetworkTableViewCell.h"
#import "_HttpModel.h"

static NSString * const _CellReuseIdentifier = @"_NetworkDetailTableViewCellReuseIdentifier";

@interface NetworkDetailViewController ()
@end

@implementation NetworkDetailViewController {
    NSMutableArray *_detailModels;
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self.navigationController action:@selector(exit)],[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_mail" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(didTapCopy:)]];
    
    self.tableView.allowsSelection = NO;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.separatorColor = [UIColor colorFromHexString:@"#4D4D4D"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:NetworkDetailTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
#ifdef __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        // iOS15 导航栏和表格视图之间 的空隙
        self.tableView.sectionHeaderTopPadding = 0.0f;
    }
#endif
    
    [self setupModels];
}

- (void)setupModels
{
    UILabel *statusCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    statusCodeLabel.font = [UIFont boldSystemFontOfSize:20];
    NSString *statusCode = self.httpModel.statusCode;
    if ([_successStatusCodes containsObject:statusCode]) {
        statusCodeLabel.textColor = [@"#42d459" hexColor];
    }
    else if ([_informationalStatusCodes containsObject:statusCode]) {
        statusCodeLabel.textColor = [@"#4b8af7" hexColor];
    }
    else if ([_redirectionStatusCodes containsObject:statusCode]) {
        statusCodeLabel.textColor = [@"#ff9800" hexColor];
    }
    else {
        statusCodeLabel.textColor = [@"#ff0000" hexColor];
    }
    if (statusCode.intValue == 0) { //"0" means network unavailable
        statusCode = @"❌";
    }
    statusCodeLabel.text = statusCode;
    [statusCodeLabel sizeToFit];
    self.navigationItem.titleView = statusCodeLabel;

    if (self.httpModel.requestData.dataToObject) {
        //JSON格式
        self.httpModel.requestSerializer = RequestSerializerJSON;
    } else {
        //Form格式
        self.httpModel.requestSerializer = RequestSerializerForm;
    }

    _detailModels = [NSMutableArray array];
    
    NetworkDetailModel *model_1 = [[NetworkDetailModel alloc] initWithTitle:[NSString stringWithFormat:@"%@ URL", self.httpModel.method] contentText:self.httpModel.url.absoluteString contentImage:nil];
    NetworkDetailModel *model_2 = [[NetworkDetailModel alloc] initWithTitle:@"Request Header" contentText:self.httpModel.requestHeaderFields.headerToString contentImage:nil];
    NSString *requestContent;
    //判断请求参数格式JSON/Form
    if (self.httpModel.requestSerializer == RequestSerializerJSON) {
        requestContent = [self.httpModel.requestData dataToPrettyPrintString];
    } else if (self.httpModel.requestSerializer == RequestSerializerForm) {
        requestContent = self.httpModel.requestData.dataToString;
    }
    if (self.httpModel.requestData) {
        requestContent = requestContent.length > 0 ? requestContent : @"not show";
    }
    NetworkDetailModel *model_3 = [[NetworkDetailModel alloc] initWithTitle:@"Request" contentText:requestContent contentImage:nil];
    model_3.contentFile = self.httpModel.logFilePath;
    NSString *startTime = [[NSDate dateWithTimeIntervalSince1970:self.httpModel.startTime.doubleValue] format];
    NSString *endTime = [[NSDate dateWithTimeIntervalSince1970:self.httpModel.endTime.doubleValue] format];
    NSString *clientString = [NSString stringWithFormat:@"\"startTime\": \"%@\",\n\"endTime\": \"%@\"", startTime, endTime];
    NetworkDetailModel *model_time = [[NetworkDetailModel alloc] initWithTitle:@"Task Time" contentText:clientString contentImage:nil];

    NetworkDetailModel *model_4 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Header" contentText:self.httpModel.responseHeaderFields.headerToString contentImage:nil];
    NetworkDetailModel *model_5 = nil;
    if (self.httpModel.isImage) {
        UIImage *image = [UIImage imageWithGIFURL:[NSURL fileURLWithPath:self.httpModel.downloadFilePath]];
        NSString *contentText = image ? nil : @"not show";
        model_5 = [[NetworkDetailModel alloc] initWithTitle:@"Responce" contentText:contentText contentImage:image];
    } else {
        NSString *contentText = self.httpModel.responseData.dataToPrettyPrintString;
        if (self.httpModel.responseData || self.httpModel.downloadFilePath) {
            contentText = contentText.length > 0 ? contentText : @"not show";
        }
        model_5 = [[NetworkDetailModel alloc] initWithTitle:@"Responce" contentText:contentText contentImage:nil];
    }
    model_5.contentFile = self.httpModel.logFilePath;
    NetworkDetailModel *model_6 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Size" contentText:self.httpModel.size contentImage:nil];
    NetworkDetailModel *model_7 = [[NetworkDetailModel alloc] initWithTitle:@"Total Time" contentText:self.httpModel.totalDuration contentImage:nil];
    NetworkDetailModel *model_8 = [[NetworkDetailModel alloc] initWithTitle:@"MIME Type" contentText:self.httpModel.mineType contentImage:nil];
    NetworkDetailModel *model_9 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Error" contentText:self.httpModel.errorLocalizedDescription contentImage:nil];
    NetworkDetailModel *model_10 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Error Description" contentText:self.httpModel.errorDescription contentImage:nil];
    [_detailModels addObject:model_1];
    if (model_2.contentText.length > 0) {
        [_detailModels addObject:model_2];
    }
    if (model_3.contentText.length > 0) {
        [_detailModels addObject:model_3];
    }
    
    [_detailModels addObject:model_time];
    
    if (model_4.contentText.length > 0) {
        [_detailModels addObject:model_4];
    }
    if (model_5.contentText.length > 0 || model_5.contentImage) {
        [_detailModels addObject:model_5];
    }
    if (model_9.contentText.length > 0) {
        [_detailModels addObject:model_9];
    }
    if (model_10.contentText.length > 0) {
        [_detailModels addObject:model_10];
    }
    if (model_6.contentText.length > 0) {
        [_detailModels addObject:model_6];
    }
    if (model_7.contentText.length > 0) {
        [_detailModels addObject:model_7];
    }
    if (@available(iOS 10.0, *)) {
        NSString *startTime = [self.httpModel.domainStartDate format];
        NSString *endTime = [self.httpModel.domainEndDate format];
        if (startTime && endTime) {
            NetworkDetailModel *model_7_d = [[NetworkDetailModel alloc] initWithTitle:@"Domain Lookup Time" contentText:[NSString stringWithFormat:@"\"startTime\": \"%@\",\n\"endTime\": \"%@\"", startTime, endTime] contentImage:nil];
            [_detailModels addObject:model_7_d];
        }
        
        startTime = [self.httpModel.secureStartDate format];
        endTime = [self.httpModel.secureEndDate format];
        if (startTime && endTime) {
            NetworkDetailModel *model_7_s = [[NetworkDetailModel alloc] initWithTitle:@"Security Handshake Time" contentText:[NSString stringWithFormat:@"\"startTime\": \"%@\",\n\"endTime\": \"%@\"", startTime, endTime] contentImage:nil];
            [_detailModels addObject:model_7_s];
        }
        
        startTime = [self.httpModel.requestStartDate format];
        endTime = [self.httpModel.requestEndDate format];
        if (startTime && endTime) {
            NetworkDetailModel *model_7_req = [[NetworkDetailModel alloc] initWithTitle:@"Request Time" contentText:[NSString stringWithFormat:@"\"startTime\": \"%@\",\n\"endTime\": \"%@\"", startTime, endTime] contentImage:nil];
            [_detailModels addObject:model_7_req];
        }
        
        startTime = [self.httpModel.responseStartDate format];
        endTime = [self.httpModel.responseEndDate format];
        if (startTime && endTime) {
            NetworkDetailModel *model_7_rsp = [[NetworkDetailModel alloc] initWithTitle:@"Response Time" contentText:[NSString stringWithFormat:@"\"startTime\": \"%@\",\n\"endTime\": \"%@\"", startTime, endTime] contentImage:nil];
            [_detailModels addObject:model_7_rsp];
        }
    }
    if (model_8.contentText.length > 0) {
        [_detailModels addObject:model_8];
    }
}

- (void)didTapCopy:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"共享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (!weakSelf) return;
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:weakSelf.httpModel.logFilePath]] applicationActivities:nil];
        [weakSelf presentViewController:activityController animated:YES completion:NULL];
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detailModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkDetailTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id content = cell.model.contentText;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    if (!cell.model.contentFile) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentLeft;
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: [UIFont systemFontOfSize:13]}];
        [alertController setValue:attributedMessage forKey:@"attributedMessage"];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拷贝" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard.generalPasteboard.string = content;
        }]];
    } else {
        content = [NSURL fileURLWithPath:cell.model.contentFile];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    cell.model = _detailModels[indexPath.row];
    return cell;
}
@end
