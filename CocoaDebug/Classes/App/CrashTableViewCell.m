//
//  CrashTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/15.
//

#import "CrashTableViewCell.h"
#import "_CrashModel.h"

@interface CrashTableViewCell ()
@property (weak, nonatomic) NSLayoutConstraint *contentH;
@end

@implementation CrashTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = UIColor.darkGrayColor;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:labelTitle];
        UILabel *textContent = [[UILabel alloc] initWithFrame:CGRectZero];
        textContent.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:textContent];
        
        id viewsDict = NSDictionaryOfVariableBindings(labelTitle,textContent);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[labelTitle]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[textContent]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[labelTitle]-(5)-[textContent]-(10)-|" options:0 metrics:nil views:viewsDict]];
        NSLayoutConstraint *contentH = [NSLayoutConstraint constraintWithItem:textContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.contentView addConstraint:contentH];
        _contentH = contentH;
        
        labelTitle.textColor = UIColor.mainGreen;
        labelTitle.font = [UIFont boldSystemFontOfSize:12];
        textContent.lineBreakMode = NSLineBreakByCharWrapping;
        textContent.font = [UIFont boldSystemFontOfSize:12];
        textContent.textColor = UIColor.whiteColor;
        textContent.numberOfLines = 0;
        
        _labelTitle = labelTitle;
        _textContent = textContent;
    }
    return self;
}

- (void)setModel:(_CrashModel *)model {
    _model = model;
    
    self.labelTitle.text = [model.date format];
    self.textContent.text = model.name?:@"unknown crash";
    CGSize size = [self.textContent sizeThatFits:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds)-30, CGFLOAT_MAX)];
    self.contentH.constant = size.height;
}
@end
