#import "LMTableViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "UIColor+applicationColors.h"
#import "AppConstant.h"

@interface LMTableViewCell()

@end

@implementation LMTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor clearColor];
        
        _cellImageView = [UIImageView new];
        [_cellImageView.layer setMasksToBounds:YES];
        [_cellImageView.layer setCornerRadius:15.0f];
        _cellImageView.contentMode = UIViewContentModeScaleToFill;
        
        _titleLabel = [UILabel new];
        _accessoryLabel = [UILabel new];
        _detailLabel = [UILabel new];
        
        for (UILabel *label in @[self.titleLabel, self.accessoryLabel, self.detailLabel]) {
            label.textColor = (label == self.titleLabel) ? [UIColor whiteColor] : [UIColor lm_wetAsphaltColor];
            label.font = (label == self.titleLabel) ? [UIFont lm_noteWorthyLarge] : [UIFont lm_noteWorthySmall];
            [label sizeToFit];
        }
        
        for (UIView *view in @[self.cellImageView, self.titleLabel, self.detailLabel, self.accessoryLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _titleLabel, _accessoryLabel, _detailLabel);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - 5);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - 5);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, 2.5);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, 10);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, 3);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _detailLabel, -8);
    CONSTRAIN_WIDTH(_detailLabel, cellWidth - 100);
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, -15);
    CONSTRAIN_HEIGHT(_accessoryLabel, self.contentView.frame.size.height);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-10-[_titleLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-10-[_detailLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
