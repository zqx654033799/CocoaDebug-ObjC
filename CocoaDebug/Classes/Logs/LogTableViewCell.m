//
//  LogTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/9.
//

#import "LogTableViewCell.h"
#import "_OCLogModel.h"
#import "CocoaDebug+Extensions.h"
#import "CustomTextView.h"
#import "_OCLoggerFormat.h"

@interface LogTableViewCell ()<UITextViewDelegate>
@property (weak, nonatomic) NSLayoutConstraint *contentH;
@end

@implementation LogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:labelTitle];
        UITextView *labelContent = [[CustomTextView alloc] initWithFrame:CGRectZero];
        labelContent.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:labelContent];
        
        id viewsDict = NSDictionaryOfVariableBindings(labelTitle, labelContent);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[labelContent]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[labelTitle]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[labelTitle][labelContent]-(10)-|" options:0 metrics:nil views:viewsDict]];
        NSLayoutConstraint *contentH = [NSLayoutConstraint constraintWithItem:labelContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.contentView addConstraint:contentH];
        
        labelTitle.font = [UIFont boldSystemFontOfSize:12];
        
        _contentH = contentH;
        _labelTitle = labelTitle;
        _labelContent = labelContent;
    }
    return self;
}

- (void)setModel:(_OCLogModel *)model {
    self.backgroundColor = model.isTag ? [@"#007aff" hexColor] : UIColor.clearColor;
    if ([model isEqual:_model]) { return; }
    _model = model;
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]", [_OCLoggerFormat formatDate:model.date]] attributes:@{NSForegroundColorAttributeName: UIColor.mainGreen}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[model.fileInfo stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] attributes:@{NSForegroundColorAttributeName: UIColor.grayColor}]];
    self.labelTitle.attributedText = title;
    self.labelContent.text = model.content;
    CGSize size = [self.labelContent sizeThatFits:CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds)-30, CGFLOAT_MAX)];
    self.contentH.constant = size.height;
}
@end
