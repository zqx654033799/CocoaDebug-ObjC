//
//  NetworkTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/10.
//

#import "NetworkTableViewCell.h"
#import "_HttpModel.h"

static NSInteger const _MAXSize = 256;

@interface NetworkTableViewCell ()
@end

@implementation NetworkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = UIColor.darkGrayColor;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        methodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:methodLabel];
        UILabel *statusCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:statusCodeLabel];
        UILabel *requestTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        requestTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:requestTimeLabel];
        UILabel *requestUrlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        requestUrlLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:requestUrlLabel];
        
        id viewsDict = NSDictionaryOfVariableBindings(methodLabel,statusCodeLabel,requestTimeLabel,requestUrlLabel);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[methodLabel]-(5)-[requestTimeLabel][statusCodeLabel(75)]|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[requestUrlLabel][statusCodeLabel]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[methodLabel(20)]-(5)-[requestUrlLabel]-(10)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(18)-[requestTimeLabel(15)]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusCodeLabel]|" options:0 metrics:nil views:viewsDict]];
        [methodLabel setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
        
        methodLabel.preferredMaxLayoutWidth = 60;
        methodLabel.textColor = [@"808080" hexColor];
        methodLabel.font = [UIFont boldSystemFontOfSize:17];
        statusCodeLabel.textAlignment = NSTextAlignmentCenter;
        statusCodeLabel.font = [UIFont boldSystemFontOfSize:17];
        statusCodeLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        
        requestTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        requestTimeLabel.textColor = UIColor.mainGreen;
        
        requestUrlLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        requestUrlLabel.lineBreakMode = NSLineBreakByCharWrapping;
        requestUrlLabel.textColor = UIColor.whiteColor;
        requestUrlLabel.numberOfLines = 0;
        
        _methodLabel = methodLabel;
        _statusCodeLabel = statusCodeLabel;
        _requestTimeLabel = requestTimeLabel;
        _requestUrlLabel = requestUrlLabel;
    }
    return self;
}

- (void)setModel:(_HttpModel *)model {
    _model = model;
    self.backgroundColor = model.isTag?[@"#007aff" hexColor]:UIColor.clearColor;
    
    self.methodLabel.text = [NSString stringWithFormat:@"[%@]", model.method];
    if (model.startTime) {
        NSDate *data = [NSDate dateWithTimeIntervalSince1970:model.startTime.doubleValue];
        self.requestTimeLabel.text = [data format];
    } else {
        self.requestTimeLabel.text = [NSDate.date format];
    }
    
    NSString *content = model.url.absoluteString;
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (contentData.length > _MAXSize) {
        content = [contentData fetchStringWithByteLength:_MAXSize];
        content = [content stringByAppendingString:@"..."];
    }
    self.requestUrlLabel.text = content;

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
