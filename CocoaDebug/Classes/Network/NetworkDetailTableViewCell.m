//
//  NetworkDetailTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import "NetworkDetailTableViewCell.h"
#import "CustomTextView.h"
#import "NSObject+CocoaDebug.h"

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
@property (weak, nonatomic, readonly) NSLayoutConstraint *contentTextH;
@end

@implementation NetworkDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:titleLabel];
        UIView *lineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:lineView];
        UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:contentImageView];
        CustomTextView *contentTextView = [[CustomTextView alloc] initWithFrame:CGRectZero];
        contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:contentTextView];
        
        id viewsDict = NSDictionaryOfVariableBindings(titleLabel,lineView,contentImageView,contentTextView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[titleLabel]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lineView]|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[contentTextView]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[contentImageView]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[titleLabel(20)][lineView(0.5)]-(5)-[contentTextView]-(5)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentImageView]-(5)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:contentImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        NSLayoutConstraint *contentTextH = [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.contentView addConstraint:contentTextH];
        _contentTextH = contentTextH;
        
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor colorFromHexString:@"#808080"];
        lineView.backgroundColor = [UIColor colorFromHexString:@"#4D4D4D"];
        
        _titleLabel = titleLabel;
        _contentTextView = contentTextView;
        _contentImageView = contentImageView;
    }
    return self;
}

- (void)setModel:(NetworkDetailModel *)model {
    self.titleLabel.text = model.title;
    if (model.contentImage) {
        self.contentImageView.hidden = NO;
        self.contentTextView.hidden = YES;
        self.contentImageView.image = model.contentImage;
        CGFloat imageHeight = (CGRectGetWidth(UIScreen.mainScreen.bounds)-30)/model.contentImage.size.width*model.contentImage.size.height;
        self.contentTextH.constant = imageHeight;
    } else {
        self.contentImageView.hidden = YES;
        self.contentTextView.hidden = NO;
        self.contentTextView.text = model.contentText;
        CGSize size = [self.contentTextView sizeThatFits:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds)-30, CGFLOAT_MAX)];
        self.contentTextH.constant = size.height;
    }
}
@end
