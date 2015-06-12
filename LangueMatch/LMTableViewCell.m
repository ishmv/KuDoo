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
        [_cellImageView.layer setMasksToBounds:YES];
        [_cellImageView.layer setCornerRadius:15.0f];
        [_cellImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_cellImageView.layer setBorderWidth:3.0f];
        
        _cellImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _titleLabel = [UILabel new];
        _accessoryLabel = [UILabel new];
        _detailLabel = [UILabel new];
        
        self.backgroundColor = [UIColor clearColor];
        
        for (UILabel *label in @[self.titleLabel, self.accessoryLabel, self.detailLabel]) {
            label.textColor = (label == self.titleLabel) ? [UIColor lm_wetAsphaltColor] : [UIColor lm_orangeColor];
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
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - 10);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - 10);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, 5);
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
