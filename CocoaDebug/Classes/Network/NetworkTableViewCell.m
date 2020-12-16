//
//  NetworkTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/10.
//

#import "NetworkTableViewCell.h"
#import "CocoaDebug+Extensions.h"
#import "CustomTextView.h"
#import "_OCLoggerFormat.h"
#import "_HttpModel.h"

@interface NetworkTableViewCell ()
@property (weak, nonatomic) NSLayoutConstraint *requestUrlH;
@end

@implementation NetworkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = UIColor.darkGrayColor;
        
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        methodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:methodLabel];
        UILabel *statusCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:statusCodeLabel];
        UITextView *requestTimeTextView = [[CustomTextView alloc] initWithFrame:CGRectZero];
        requestTimeTextView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:requestTimeTextView];
        UITextView *requestUrlTextView = [[CustomTextView alloc] initWithFrame:CGRectZero];
        requestUrlTextView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:requestUrlTextView];
        
        id viewsDict = NSDictionaryOfVariableBindings(methodLabel,statusCodeLabel,requestTimeTextView,requestUrlTextView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[methodLabel]-(5)-[requestTimeTextView][statusCodeLabel(75)]|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[requestUrlTextView][statusCodeLabel]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[methodLabel]-(5)-[requestUrlTextView]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(18)-[requestTimeTextView(15)]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusCodeLabel]|" options:0 metrics:nil views:viewsDict]];
        NSLayoutConstraint *requestUrlH = [NSLayoutConstraint constraintWithItem:requestUrlTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.contentView addConstraint:requestUrlH];
        
        methodLabel.textColor = [@"808080" hexColor];
        methodLabel.font = [UIFont boldSystemFontOfSize:17];
        statusCodeLabel.textAlignment = NSTextAlignmentCenter;
        statusCodeLabel.font = [UIFont boldSystemFontOfSize:17];
        statusCodeLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        
        requestTimeTextView.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        requestTimeTextView.textColor = UIColor.mainGreen;
        requestTimeTextView.selectable = YES;
        
        requestUrlTextView.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        requestUrlTextView.selectable = YES;
        
        _requestUrlH = requestUrlH;
        _methodLabel = methodLabel;
        _statusCodeLabel = statusCodeLabel;
        _requestTimeTextView = requestTimeTextView;
        _requestUrlTextView = requestUrlTextView;
    }
    return self;
}

- (void)setModel:(_HttpModel *)model {
    self.backgroundColor = model.isTag?[@"#007aff" hexColor]:UIColor.clearColor;
    if ([model isEqual:_model]) { return; }
    _model = model;
    
    self.methodLabel.text = [NSString stringWithFormat:@"[%@]", model.method];
    if (model.startTime) {
        NSDate *data = [NSDate dateWithTimeIntervalSince1970:model.startTime.doubleValue];
        self.requestTimeTextView.text = [_OCLoggerFormat formatDate:data];
    } else {
        self.requestTimeTextView.text = [_OCLoggerFormat formatDate:NSDate.date];
    }
    
    self.requestUrlTextView.text = model.url.absoluteString;
    CGSize size = [self.requestUrlTextView sizeThatFits:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds)-85, CGFLOAT_MAX)];
    self.requestUrlH.constant = size.height;

    NSString *statusCode = model.statusCode;
    
    if ([_successStatusCodes containsObject:statusCode]) {
        self.statusCodeLabel.textColor = [@"#42d459" hexColor];
    }
    else if ([_informationalStatusCodes containsObject:statusCode]) {
        self.statusCodeLabel.textColor = [@"#4b8af7" hexColor];
    }
    else if ([_redirectionStatusCodes containsObject:statusCode]) {
        self.statusCodeLabel.textColor = [@"#ff9800" hexColor];
    }
    else {
        self.statusCodeLabel.textColor = [@"#ff0000" hexColor];
    }
    if (statusCode.intValue == 0) { //"0" means network unavailable
        statusCode = @"❌";
    }
    self.statusCodeLabel.text = statusCode;
}
@end
