#import "LMForumTableViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "AppConstant.h"

@interface LMForumTableViewCell()

@property (strong, nonatomic) UIView *backgroundColorView;

@end

@implementation LMForumTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _cellImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView.layer setMasksToBounds:YES];
            [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [imageView.layer setBorderWidth:2.0f];
            imageView;
        });
        
        _titleLabel = [UILabel new];
        _detailLabel = [UILabel new];
        _infoLabel = [UILabel new];
        
        _accessoryLabel = ({
            UILabel *label = [UILabel new];
            [label.layer setCornerRadius:15.0f];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor lm_tealBlueColor];
            [label.layer setMasksToBounds:YES];
            label;
        });
        
        for (UILabel *label in @[_titleLabel, _infoLabel, _accessoryLabel, _detailLabel]) {
            label.textColor = (label == self.titleLabel) ? [UIColor whiteColor] : [UIColor whiteColor];
            label.font = (label == self.titleLabel) ? [UIFont lm_robotoRegularForumTitle] : [UIFont lm_robotoRegular];
            [label sizeToFit];
        }
        
        _detailLabel.font = [UIFont lm_robotoLightTimestamp];
        
        _backgroundColorView = [[UIView alloc] init];
        _backgroundColorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        
        for (UIView *view in @[_backgroundColorView, _cellImageView, _titleLabel, _infoLabel, _detailLabel, _accessoryLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cellImageView, _titleLabel, _infoLabel, _accessoryLabel, _detailLabel);
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CONSTRAIN_HEIGHT(_cellImageView, cellHeight - 50);
    CONSTRAIN_WIDTH(_cellImageView, cellHeight - 50);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _cellImageView, 25);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, _cellImageView, 16);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _titleLabel, 8);
    CONSTRAIN_WIDTH(_titleLabel, cellWidth - cellHeight - 30);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.contentView, _infoLabel, -14.0f);
    CONSTRAIN_WIDTH(_infoLabel, cellWidth - cellHeight - 8);
    
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _detailLabel, cellHeight/2.0f - 18.0f);
    CONSTRAIN_WIDTH(_detailLabel, cellWidth - cellHeight - 8);
    
    CONSTRAIN_HEIGHT(_accessoryLabel, 30);
    CONSTRAIN_WIDTH(_accessoryLabel, 30);
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _accessoryLabel, -8);
    ALIGN_VIEW_TOP_CONSTANT(self.contentView, _accessoryLabel, 8);
    
    [self.cellImageView.layer setCornerRadius:cellHeight/2.0f - 25];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-20-[_titleLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-20-[_infoLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellImageView]-36-[_detailLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    _backgroundColorView.frame = CGRectMake(0, 0, cellWidth, cellHeight);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
