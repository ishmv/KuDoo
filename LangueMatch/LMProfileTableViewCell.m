#import "LMProfileTableViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "AppConstant.h"

@interface LMProfileTableViewCell()

@property (strong, nonatomic) UIView *lineView;

@end

@implementation LMProfileTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        _cellImageView = [UIImageView new];
        _cellImageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleLabel = [UILabel new];
        _accessoryLabel = [UILabel new];
        _lineView = [UIView new];
        _lineView.backgroundColor = [[UIColor lm_tealColor] colorWithAlphaComponent:0.7f];
        
        [_titleLabel sizeToFit];
        
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.backgroundColor = [UIColor clearColor];
        
        for (UILabel *label in @[self.titleLabel, self.accessoryLabel]) {
            label.textColor = (label == self.titleLabel) ? [UIColor lm_wetAsphaltColor] : [UIColor lm_orangeColor];
            label.font = (label == self.titleLabel) ? [UIFont lm_noteWorthyMedium] : [UIFont lm_noteWorthySmall];
            [label sizeToFit];
        }
        
        for (UIView *view in @[self.cellImageView, self.lineView, self.titleLabel, self.accessoryLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _lineView, _titleLabel, _accessoryLabel);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CONSTRAIN_HEIGHT(_cellImageView, _imageWidth);
    CONSTRAIN_WIDTH(_cellImageView, _imageWidth);
    ALIGN_VIEW_TOP(self.contentView, _cellImageView);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, 20);
    
    CONSTRAIN_WIDTH(_lineView, 2);
    CONSTRAIN_HEIGHT(_lineView, cellHeight);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, 3);

    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, -15);
    CONSTRAIN_HEIGHT(_accessoryLabel, self.contentView.frame.size.height);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-15-[_lineView]-10-[_titleLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    _titleLabel.preferredMaxLayoutWidth = cellWidth - 90;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
