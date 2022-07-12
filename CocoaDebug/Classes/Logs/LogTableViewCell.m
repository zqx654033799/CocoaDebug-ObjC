//
//  LogTableViewCell.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/9.
//

#import "LogTableViewCell.h"
#import "_OCLogModel.h"

@interface LogTableViewCell ()
@end

@implementation LogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:labelTitle];
        UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectZero];
        labelContent.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:labelContent];
        
        id viewsDict = NSDictionaryOfVariableBindings(labelTitle, labelContent);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[labelContent]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[labelTitle]-(15)-|" options:0 metrics:nil views:viewsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[labelTitle(15)][labelContent]-(10)-|" options:0 metrics:nil views:viewsDict]];
        
        labelTitle.font = [UIFont boldSystemFontOfSize:12];
        labelContent.font = [UIFont boldSystemFontOfSize:12];
        labelContent.lineBreakMode = NSLineBreakByCharWrapping;
        labelContent.textColor = UIColor.whiteColor;
        labelContent.numberOfLines = 0;
        
        _labelTitle = labelTitle;
        _labelContent = labelContent;
    }
    return self;
}

- (void)setModel:(_OCLogModel *)model {
    _model = model;
    self.backgroundColor = model.isTag ? [@"#007aff" hexColor] : UIColor.clearColor;

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]", [model.date format]] attributes:@{NSForegroundColorAttributeName: UIColor.mainGreen}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:model.fileInfo attributes:@{NSForegroundColorAttributeName: UIColor.grayColor}]];
    self.labelTitle.attributedText = title;
    self.labelContent.text = model.content;
}
@end
