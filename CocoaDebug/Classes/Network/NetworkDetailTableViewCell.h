//
//  NetworkDetailTableViewCell.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/13.
//

#import <UIKit/UIKit.h>

@interface NetworkDetailModel : NSObject

- (instancetype)initWithTitle:(NSString *)title contentText:(NSString *)contentText contentImage:(UIImage *)contentImage;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *contentText;
@property (copy, nonatomic) UIImage *contentImage;

@end

@interface NetworkDetailTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *titleLabel;
@property (weak, nonatomic, readonly) UITextView *contentTextView;
@property (weak, nonatomic, readonly) UIImageView *contentImageView;

@property (weak, nonatomic) NetworkDetailModel *model;

@end
