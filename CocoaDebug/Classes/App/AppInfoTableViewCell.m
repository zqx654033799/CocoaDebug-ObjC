//
//  AppInfoTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/8.
//

#import "AppInfoTableViewCell.h"
#import "NSObject+CocoaDebug.h"
#import "AppInfoModel.h"

@interface AppInfoTableViewCell ()
@property (weak, nonatomic, readonly) NSLayoutConstraint *leftImageViewW;
@property (weak, nonatomic, readonly) NSLayoutConstraint *leftLableL;
@property (weak, nonatomic, readonly) NSLayoutConstraint *leftLableW;
@end

@implementation AppInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorFromHexString:@"#333333"];
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorFromHexString:@"#444444"];
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
        UILabel *leftLable = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLable.translatesAutoresizingMaskIntoConstraints = NO;
        UILabel *rightLable = [[UILabel alloc] initWithFrame:CGRectZero];
        rightLable.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:leftImageView];
        [self.contentView addSubview:leftLable];
        [self.contentView addSubview:rightLable];
        
        id viewsDict = NSDictionaryOfVariableBindings(leftImageView,leftLable,rightLable);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[leftImageView]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftLable]-(5)-[rightLable]-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftImageView(30)]" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[leftLable]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[rightLable]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        
        NSLayoutConstraint *leftImageViewW = [NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        [leftImageView addConstraint:leftImageViewW];
        _leftImageViewW = leftImageViewW;
        NSLayoutConstraint *leftLableL = [NSLayoutConstraint constraintWithItem:leftLable attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leftImageView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [self.contentView addConstraint:leftLableL];
        NSLayoutConstraint *leftLableW = [NSLayoutConstraint constraintWithItem:leftLable attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
        [self.contentView addConstraint:leftLableW];
        _leftLableL = leftLableL;
        _leftLableW = leftLableW;
        
        leftLable.textColor = [UIColor colorFromHexString:@"#B8B8B8"];
        rightLable.textColor = [UIColor whiteColor];
        leftLable.font = [UIFont systemFontOfSize:17];
        rightLable.font = [UIFont systemFontOfSize:17];
        leftLable.numberOfLines = 1;
        leftLable.adjustsFontSizeToFitWidth = YES;
        rightLable.numberOfLines = 0;
        rightLable.textAlignment = NSTextAlignmentRight;
        rightLable.lineBreakMode = NSLineBreakByCharWrapping;
        _leftImageView = leftImageView;
        _leftLable = leftLable;
        _rightLable = rightLable;
    }
    return self;
}

- (void)setModel:(AppInfoModel *)model {
    if (model && [model isEqual:_model]) {
        return;
    }
    _model = model;
    
    self.leftImageView.image = model.image;
    self.leftImageViewW.constant = model.image ? 30 : 0;
    self.leftLableL.constant = model.image ? 5 : 0;

    self.leftLable.text = model.leftString;
    CGSize size = [self.leftLable sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
    self.leftLableW.constant = size.width>120?120:size.width;
    
    self.rightLable.text = model.rightString;
    self.accessoryView = model.accessoryView;
}
@end
