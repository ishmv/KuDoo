#import "LMTableViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "AppConstant.h"

@interface LMTableViewCell()

@property (strong, nonatomic) UILabel *customAccessoryView;

@end

@implementation LMTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        _cellImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView.layer setMasksToBounds:YES];
            [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [imageView.layer setBorderWidth:2.0f];
            imageView;
        });

        _titleLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont lm_robotoRegularTitle];
            [label sizeToFit];
            label;
        });
        
        _detailLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lm_tealBlueColor];
            label.font = [UIFont lm_robotoLightMessagePreview];
            [label sizeToFit];
            label;
        });
        
        _accessoryLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lm_orangeColor];
            label.font = [UIFont lm_robotoLightTimestamp];
            [label sizeToFit];
            label;
        });
        
        _customAccessoryView = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lm_slateColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont lm_robotoLightTimestamp];
            label.textAlignment = NSTextAlignmentCenter;
            [label.layer setCornerRadius:12.5f];
            [label.layer setMasksToBounds:YES];
            label;
        });
        
        for (UIView *view in @[_cellImageView, _titleLabel, _detailLabel, _accessoryLabel, _customAccessoryView]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

#define CONSTRAIN_VISUALLY(FORMAT) [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:viewDictionary]]

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _titleLabel, _accessoryLabel, _detailLabel, _customAccessoryView);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - 10);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - 10);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, 5);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, 8);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, 12);
    CONSTRAIN_WIDTH(_titleLabel, cellWidth - 150);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _detailLabel, -12);
    CONSTRAIN_WIDTH(_detailLabel, cellWidth - 150);
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, -20);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _accessoryLabel, 19);
    
    CONSTRAIN_WIDTH(_customAccessoryView, 25);
    CONSTRAIN_HEIGHT(_customAccessoryView, 25);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _customAccessoryView, -13);
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _customAccessoryView, -20);
    
    [self.cellImageView.layer setCornerRadius:cellHeight/2.0f - 5];
    
    CONSTRAIN_VISUALLY(@"H:[_cellImageView]-15-[_titleLabel]");
    CONSTRAIN_VISUALLY(@"H:[_cellImageView]-15-[_detailLabel]");
}

#pragma mark - Setter methods

- (void) setCustomAccessoryLabelText:(NSString *)customAccessoryLabelText
{
    _customAccessoryLabelText = [customAccessoryLabelText copy];
    
    if (![customAccessoryLabelText isEqualToString:@"0"] && customAccessoryLabelText != nil) {
        _customAccessoryView.backgroundColor = [UIColor whiteColor];
        _customAccessoryView.text = customAccessoryLabelText;
    } else {
        _customAccessoryView.backgroundColor = [UIColor clearColor];
        _customAccessoryView.text = @"";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
