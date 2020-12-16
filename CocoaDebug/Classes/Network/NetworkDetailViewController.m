//
//  NetworkDetailViewController.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import "NetworkDetailViewController.h"
#import "NetworkDetailTableViewCell.h"
#import "NetworkTableViewCell.h"
#import "NSObject+CocoaDebug.h"
#import "_HttpModel.h"
#import "CocoaDebug+Extensions.h"
#import "_GPBMessage.h"
#import "_OCLoggerFormat.h"

static NSString * const _CellReuseIdentifier = @"_NetworkDetailTableViewCellReuseIdentifier";

@interface NetworkDetailViewController ()
@property (strong, nonatomic) NetworkTableViewCell *headerCell;
@end

@implementation NetworkDetailViewController {
    NSMutableArray *_detailModels;
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self.navigationController action:@selector(exit)],[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_mail" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(didTapMail:)]];
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor colorFromHexString:@"#4D4D4D"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:NetworkDetailTableViewCell.class forCellReuseIdentifier:_CellReuseIdentifier];
    
    _headerCell = [[NetworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    _headerCell.contentView.backgroundColor = UIColor.blackColor;
    _headerCell.model = self.httpModel;
    
    [self setupModels];
}

- (void)setupModels
{
    if (self.httpModel.requestData.dataToDictionary) {
        //JSON格式
        self.httpModel.requestSerializer = RequestSerializerJSON;
    } else {
        //Form格式
        self.httpModel.requestSerializer = RequestSerializerForm;
    }

    if (self.httpModel.requestData == nil) {
        self.httpModel.requestData = NSData.new;
    }
    if (self.httpModel.responseData == nil) {
        self.httpModel.responseData = NSData.new;
    }
    _detailModels = [NSMutableArray array];
    
    NSString *requestContent;
    //判断请求参数格式JSON/Form
    if (self.httpModel.requestSerializer == RequestSerializerJSON) {
        //JSON
        requestContent = [self.httpModel.requestData dataToPrettyPrintString];
    } else if (self.httpModel.requestSerializer == RequestSerializerForm) {
        //1.protobuf
        _GPBMessage *message = [_GPBMessage parseFromData:self.httpModel.requestData error:nil];
        if (message.serializedSize > 0) {
            requestContent = message.description;
        } else {
            //2.Form
            requestContent = self.httpModel.requestData.dataToString;
        }
        if (requestContent == nil || [@"" isEqualToString:requestContent] || [@"\\u{8}\\u{1e}" isEqualToString:requestContent]) {
            //3.utf-8 string
            requestContent = self.httpModel.requestData.dataToString;
        }
        if (requestContent == nil || [@"\\u{8}\\u{1e}" isEqualToString:requestContent]) {
            requestContent = nil;
        }
    }
    
    //NetworkDetailModel *model_1 = [[NetworkDetailModel alloc] initWithTitle:@"URL" contentText:self.httpModel.url.absoluteString contentImage:nil];
    NetworkDetailModel *model_2 = [[NetworkDetailModel alloc] initWithTitle:@"Request Header" contentText:self.httpModel.requestHeaderFields.headerToString contentImage:nil];
    NetworkDetailModel *model_3 = [[NetworkDetailModel alloc] initWithTitle:@"Request" contentText:requestContent contentImage:nil];
    NSString *startTime = [_OCLoggerFormat formatDate:[NSDate dateWithTimeIntervalSince1970:self.httpModel.startTime.doubleValue]];
    NSString *endTime = [_OCLoggerFormat formatDate:[NSDate dateWithTimeIntervalSince1970:self.httpModel.endTime.doubleValue]];
    NSString *jsonString = [NSString stringWithFormat:@"\"clientStartTime\": \"%@\",\n\"clientEndTime\": \"%@\"", startTime, endTime];
    NetworkDetailModel *model_pm = [[NetworkDetailModel alloc] initWithTitle:@"客户端记录时间" contentText:jsonString contentImage:nil];
    NetworkDetailModel *model_4 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Header" contentText:self.httpModel.responseHeaderFields.headerToString contentImage:nil];
    NetworkDetailModel *model_5 = nil;
    if (self.httpModel.isImage) {
        model_5 = [[NetworkDetailModel alloc] initWithTitle:@"Responce" contentText:nil contentImage:[UIImage imageWithGIFData:self.httpModel.responseData]];
    } else {
        model_5 = [[NetworkDetailModel alloc] initWithTitle:@"Responce" contentText:self.httpModel.responseData.dataToPrettyPrintString contentImage:nil];
    }
    NetworkDetailModel *model_6 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Size" contentText:self.httpModel.size contentImage:nil];
    NetworkDetailModel *model_7 = [[NetworkDetailModel alloc] initWithTitle:@"Total Time" contentText:self.httpModel.totalDuration contentImage:nil];
    NetworkDetailModel *model_8 = [[NetworkDetailModel alloc] initWithTitle:@"MIME Type" contentText:self.httpModel.mineType contentImage:nil];
    NetworkDetailModel *model_9 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Error" contentText:self.httpModel.errorLocalizedDescription contentImage:nil];
    NetworkDetailModel *model_10 = [[NetworkDetailModel alloc] initWithTitle:@"Responce Error Description" contentText:self.httpModel.errorDescription contentImage:nil];
    //[_detailModels addObject:model_1];
    if (model_2.contentText.length > 0) {
        [_detailModels addObject:model_2];
    }
    if (model_3.contentText.length > 0) {
        [_detailModels addObject:model_3];
    }
    [_detailModels addObject:model_pm];
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
    if (model_8.contentText.length > 0) {
        [_detailModels addObject:model_8];
    }
}

- (void)didTapMail:(id)sender {
    NSMutableString *messageBody = [NSMutableString string];
    for (NetworkDetailModel *model in _detailModels) {
        NSString *string = nil;
        if (model.contentText.length > 0) {
            string = [NSString stringWithFormat:@"\n\n------- %@ -------\n%@", model.title, model.contentText];
        }
        if (string) {
            if (![messageBody containsString:string]) {
                [messageBody appendString:string];
            }
        }
    }
    UIPasteboard.generalPasteboard.string = messageBody;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"copied detail to clipboard" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detailModels.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _headerCell.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellReuseIdentifier forIndexPath:indexPath];
    cell.model = _detailModels[indexPath.row];
    return cell;
}
@end
