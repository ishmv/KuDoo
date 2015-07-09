#import "LMTableViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "AppConstant.h"

@interface LMTableViewCell()

@end

@implementation LMTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _cellImageView = [UIImageView new];
        _cellImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _titleLabel = [UILabel new];
        _accessoryLabel = [UILabel new];
        _detailLabel = [UILabel new];
        _customAccessoryView = [UILabel new];
        
        self.backgroundColor = [UIColor clearColor];
        
        for (UILabel *label in @[self.titleLabel, self.accessoryLabel, self.detailLabel]) {
            label.textColor = (label == self.titleLabel) ? [UIColor lm_wetAsphaltColor] : [UIColor lm_orangeColor];
            label.font = (label == self.titleLabel) ? [UIFont lm_robotoRegularTitle] : [UIFont lm_robotoLightTimestamp];
            [label sizeToFit];
        }
        
        _detailLabel.font = [UIFont lm_robotoLightMessagePreview];
        _accessoryLabel.textColor = [UIColor lm_tealColor];
        
        for (UIView *view in @[self.cellImageView, self.titleLabel, self.detailLabel, self.accessoryLabel, self.customAccessoryView]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _titleLabel, _accessoryLabel, _detailLabel, _customAccessoryView);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - 10);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - 5);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, 5);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, 15);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, 13);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _detailLabel, -15);
    CONSTRAIN_WIDTH(_detailLabel, cellWidth - 160);
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, -20);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _accessoryLabel, 19);
    
    CONSTRAIN_WIDTH(_customAccessoryView, 25);
    CONSTRAIN_HEIGHT(_customAccessoryView, 25);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _customAccessoryView, -13);
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _customAccessoryView, -20);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-20-[_titleLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-20-[_detailLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
