#import "LMHomeScreenViewControllerCell.h"
#import "UIFont+ApplicationFonts.h"

@interface LMHomeScreenViewControllerCell()

@property (nonatomic, strong) UIImageView *buttonImageView;
@property (nonatomic, strong) UILabel *buttonTitleLabel;

@end

@implementation LMHomeScreenViewControllerCell

static UIFont *buttonFont;

+(void)load
{
    buttonFont = [UIFont applicationFontLarge];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_buttonTitleLabel, _buttonImageView);
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonTitleLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buttonTitleLabel(==70)][_buttonImageView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [[self layer] setBorderWidth:2.0f];
    [[self layer] setBorderColor:[UIColor whiteColor].CGColor];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.contentView.frame];
    toolbar.alpha = 0.5;
    [self.contentView addSubview:toolbar];
    [self.contentView sendSubviewToBack:toolbar];
    
//    [self addButtonMask];
}

-(void)setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle = buttonTitle;
    
    self.buttonTitleLabel = [UILabel new];
    self.buttonTitleLabel.text = buttonTitle;
    self.buttonTitleLabel.font = buttonFont;
    self.buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonTitleLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:self.buttonTitleLabel];
}

-(void)setButtonImage:(UIImage *)buttonImage
{
    _buttonImage = buttonImage;
    
    self.buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.buttonImageView.image = buttonImage;
    self.buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.buttonImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.buttonImageView];
}

-(void)setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    
    self.contentView.backgroundColor = buttonColor;
}

-(void) addButtonMask
{
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    self.contentView.layer.mask = mask;
}

@end
