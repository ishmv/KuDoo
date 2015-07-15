#import "LMLanguagePicker.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "CALayer+BackgroundLayers.h"
#import "UIButton+TapAnimation.h"

@interface LMLanguagePicker ()

@property (strong, nonatomic, readwrite) NSArray *titles;
@property (strong, nonatomic, readwrite) NSArray *images;

@property (strong, nonatomic) UILabel *pickerTitleLabel;
@property (strong, nonatomic) UILabel *pickerFooterLabel;
@property (strong, nonatomic) UIButton *continueButton;

@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@property (copy, nonatomic) void (^LMLanguageSelectionBlock)(NSInteger idx);

@end

@implementation LMLanguagePicker

#pragma mark - View Lifecycle

-(instancetype) initWithTitles:(NSArray *)titles images:(NSArray *)images andCompletion:(LMLanguageSelectionBlock)completion {
    if (self = [super init]) {
        _titles = titles;
        _images = images;
        _LMLanguageSelectionBlock = completion;
        
        //Setup background views and effects
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffect.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [visualEffect.contentView addSubview:vibrancyEffectView];
        
        [self.view addSubview:visualEffect];

        self.imageLayer = ({
            CALayer *layer = [CALayer layer];
            layer.contents = (id)[UIImage imageNamed:@"personTyping"].CGImage;
            layer.contentsGravity = kCAGravityResizeAspect;
            layer.frame = self.view.frame;
            layer;
        });
        
        [self.view.layer insertSublayer:_imageLayer atIndex:0];
        
        //Set Default Values
        _rowWidth = (CGRectGetWidth(self.view.frame) - 50.0f);
        _rowHeight = 60.0f;
        _pickerTitle = @"";
        _pickerFooter = @"";
        
        _pickerTitleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont lm_robotoLightLarge];
            label;
        });
        
        _pickerFooterLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont lm_robotoLightMessage];
            label;
        });
        
        for (UILabel *label in @[_pickerTitleLabel, _pickerFooterLabel]) {
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = _pickerFooter;
        }
        
        _picker = ({
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            pickerView;
        });
        
        for (UIView *view in @[_pickerTitleLabel, _picker, _pickerFooterLabel, _continueButton]) {
            [self.view addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    
    _continueButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [button.layer setCornerRadius:30.0f];
        [button.layer setBackgroundColor:[UIColor lm_tealColor].CGColor];
        [button setClipsToBounds:YES];
        button;
    });
    
    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [label setFont:[UIFont lm_robotoRegularTitle]];
        [label setText:NSLocalizedString(@"Language Picker", @"Language Picker")];
        label;
    });

    [self.navigationItem setTitleView:titleLabel];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_pickerTitleLabel, _picker, _pickerFooterLabel);
    
    CENTER_VIEW(self.view, _picker);
    CONSTRAIN_WIDTH(_picker, _rowWidth);
    
    CENTER_VIEW_H(self.view, _pickerTitleLabel);
    CONSTRAIN_WIDTH(_pickerTitleLabel, _rowWidth);
    
    CENTER_VIEW_H(self.view, _pickerFooterLabel);
    CONSTRAIN_WIDTH(_pickerFooterLabel, _rowWidth);
    
    CONSTRAIN_HEIGHT(_continueButton, 60);
    CONSTRAIN_WIDTH(_continueButton, 60);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.view, _continueButton, -15);
    CENTER_VIEW_H(self.view, _continueButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pickerTitleLabel]-50-[_picker]-10-[_pickerFooterLabel]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIPickerView Data Source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.titles.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *rowView = view;
    
    if (!view) {
        rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rowWidth, _rowHeight)];
        
        UIImageView *imageView;
        
        if ([self.images[row] isKindOfClass:[UIImage class]]) {
            imageView = [[UIImageView alloc] initWithImage:self.images[row]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(5, 5, _rowHeight - 10, _rowHeight - 10);
        }
        
        UILabel *tView = (UILabel *)view;
        tView = [[UILabel alloc] init];
        tView.frame = CGRectMake(0, 0, _rowWidth, _rowHeight);
        [tView setFont:[UIFont lm_robotoLightLarge]];
        tView.textColor = [UIColor whiteColor];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.numberOfLines = 7;
        tView.text = self.titles[row];
        
        [rowView addSubview:tView];
        [rowView addSubview:imageView];
    }
    
    return rowView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return _rowHeight;
}

#pragma mark - UIPickerView Delegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.titles[row];
}

#pragma mark - Touch Handling
-(void) continueButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    self.LMLanguageSelectionBlock([self.picker selectedRowInComponent:0]);
}

#pragma mark - Setter Methods

-(void) setPickerTitle:(NSString *)pickerTitle
{
    _pickerTitle = pickerTitle;
    self.pickerTitleLabel.text = pickerTitle;
}

-(void) setPickerFooter:(NSString *)pickerFooter
{
    _pickerFooter = pickerFooter;
    self.pickerFooterLabel.text = pickerFooter;
}

@end
