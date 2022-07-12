//
//  NetworkDetailTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import "NetworkDetailTableViewCell.h"

@implementation NetworkDetailModel
- (instancetype)initWithTitle:(NSString *)title contentText:(NSString *)contentText contentImage:(UIImage *)contentImage;
{
    self = [super init];
    if (self) {
        _title = title;
        _contentText = contentText;
        _contentImage = contentImage;
    }
    return self;
}
@end

@interface NetworkDetailTableViewCell ()
@property (weak, nonatomic, readonly) NSLayoutConstraint *contentImageH;
@end

@implementation NetworkDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:titleLabel];
        UIView *lineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:lineView];
        UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:contentImageView];
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:contentLabel];
        
        id viewsDict = NSDictionaryOfVariableBindings(titleLabel,lineView,contentImageView,contentLabel);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[titleLabel]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lineView]|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[contentLabel]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[contentImageView]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[titleLabel(20)][lineView(0.5)]-(5)-[contentLabel]-(5)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentImageView]-(5)-|" options:0 metrics:nil views:viewsDict]];
        NSLayoutConstraint *equalTextImage = [NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:contentImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        equalTextImage.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:equalTextImage];
        NSLayoutConstraint *contentImageH = [NSLayoutConstraint constraintWithItem:contentImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        contentImageH.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:contentImageH];
        _contentImageH = contentImageH;
        
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = UIColor.darkGrayColor;
        lineView.backgroundColor = [UIColor colorFromHexString:@"#4D4D4D"];
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        contentLabel.font = [UIFont boldSystemFontOfSize:12];
        contentLabel.textColor = UIColor.whiteColor;
        contentLabel.numberOfLines = 0;
        
        _titleLabel = titleLabel;
        _contentLabel = contentLabel;
        _contentImageView = contentImageView;
    }
    return self;
}

- (void)setModel:(NetworkDetailModel *)model {
    _model = model;

    self.titleLabel.text = model.title;
    if (model.contentImage) {
        self.contentImageView.hidden = NO;
        self.contentLabel.hidden = YES;
        self.contentImageView.image = model.contentImage;
        self.contentLabel.text = nil;
        CGFloat imageHeight = (CGRectGetWidth(UIScreen.mainScreen.bounds)-30)/model.contentImage.size.width*model.contentImage.size.height;
        self.contentImageH.priority = UILayoutPriorityRequired;
        self.contentImageH.constant = imageHeight;
    } else {
        self.contentImageView.hidden = YES;
        self.contentLabel.hidden = NO;
        self.contentImageView.image = nil;
        self.contentLabel.text = model.contentText;
        self.contentImageH.priority = UILayoutPriorityDefaultLow;
        self.contentImageH.constant = 0;
    }
}
@end
