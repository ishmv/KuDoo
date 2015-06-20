//
//  LMLanguagePicker.m
//  simplechat
//
//  Created by Travis Buttaccio on 6/2/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

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
        
        //Set Default Values:
        _rowWidth = (CGRectGetWidth(self.view.frame) - 50.0f);
        _rowHeight = 60.0f;
        _pickerTitle = @"Picker";
        _pickerFooter = @"";
        _buttonTitle = @"Continue";
        
        _picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.picker.dataSource = self;
        self.picker.delegate = self;
        
        _pickerFooterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pickerTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        for (UILabel *label in @[_pickerTitleLabel, _pickerFooterLabel]) {
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = _pickerFooter;
        }
        
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_continueButton setTitle:_buttonTitle forState:UIControlStateNormal];
        [_continueButton addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[_pickerTitleLabel, _picker, _pickerFooterLabel, _continueButton]) {
            [self.view addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [self p_renderBackground];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    CONSTRAIN_WIDTH(_continueButton, _rowWidth);
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
        [tView setFont:[UIFont lm_noteWorthyLarge]];
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

#pragma mark - Private Methods

-(void) p_renderBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageLayer = [CALayer layer];
    self.imageLayer.contents = (id)[UIImage imageNamed:@"sunrise"].CGImage;
    self.imageLayer.contentsGravity = kCAGravityResizeAspectFill;
    self.imageLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_imageLayer atIndex:0];
    
    self.gradientLayer = [CALayer lm_universalBackgroundColor];
    self.gradientLayer.frame = self.view.frame;
    
    [[self.view layer] insertSublayer:_gradientLayer above:_imageLayer];
    [[self.view layer] setShadowColor:[UIColor whiteColor].CGColor];
    
    [self.continueButton.layer setCornerRadius:10.0];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:[UIFont lm_noteWorthyMedium]];
    [self.continueButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.continueButton.layer setBorderWidth:1.0f];
    [self.continueButton.layer setBackgroundColor:[UIColor lm_tealBlueColor].CGColor];
    [self.continueButton setClipsToBounds:YES];
    
    self.pickerTitleLabel.textColor = [UIColor whiteColor];
    self.pickerTitleLabel.font = [UIFont lm_noteWorthyMedium];
    
    self.pickerFooterLabel.textColor = [UIColor whiteColor];
    self.pickerFooterLabel.font = [UIFont lm_noteWorthyMedium];
    
}

#pragma mark - Setter Methods

-(void) setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle = buttonTitle;
    [_continueButton setTitle:_buttonTitle forState:UIControlStateNormal];
}

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
