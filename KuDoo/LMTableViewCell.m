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
        
        _minimumEdgeSpacing = 12.0f;
        _cellImageViewPadding = 0.0f;
        _titleOffset = 0.0f;
        
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
            label;
        });
        
        _detailLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lm_tealBlueColor];
            label.font = [UIFont lm_robotoLightMessagePreview];
            label;
        });
        
        _accessoryLabel = ({
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lm_orangeColor];
            label.font = [UIFont lm_robotoLightTimestamp];
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

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _titleLabel, _accessoryLabel, _detailLabel, _customAccessoryView);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat customAccessoryViewSize = 25.0f;
    CGFloat imageViewSpacing = 16.0f;
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - _cellImageViewPadding);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - _cellImageViewPadding);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, _minimumEdgeSpacing/2.0f);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, _minimumEdgeSpacing);

    CGFloat titleLabelHeight = _titleLabel.font.pointSize;
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, cellHeight/2.0f - titleLabelHeight - _minimumEdgeSpacing/2.0f + _titleOffset);
    CONSTRAIN_WIDTH(_titleLabel, cellWidth - cellHeight - imageViewSpacing - _minimumEdgeSpacing * 2.0f - customAccessoryViewSize);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _detailLabel, cellHeight/2.0f + _minimumEdgeSpacing/2.0f);
    CONSTRAIN_WIDTH(_detailLabel, cellWidth - cellHeight - imageViewSpacing - _minimumEdgeSpacing - customAccessoryViewSize);
    
    CGFloat accessoryLabelHeight = _accessoryLabel.font.pointSize;
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, - _minimumEdgeSpacing);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _accessoryLabel, cellHeight/2.0 - accessoryLabelHeight - _minimumEdgeSpacing/1.5f);
    
    CONSTRAIN_WIDTH(_customAccessoryView, customAccessoryViewSize);
    CONSTRAIN_HEIGHT(_customAccessoryView, customAccessoryViewSize);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _customAccessoryView, cellHeight/2.0 + _minimumEdgeSpacing/3.0f);
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _customAccessoryView, - _minimumEdgeSpacing);
    
    [self.cellImageView.layer setCornerRadius: (cellHeight - _cellImageViewPadding)/2.0f];
    
    CONSTRAIN_VISUALLY(self.contentView, @"H:[_cellImageView]-15-[_titleLabel]");
    CONSTRAIN_VISUALLY(self.contentView, @"H:[_cellImageView]-15-[_detailLabel]");
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
