//
//  LMLanguagePicker.m
//  simplechat
//
//  Created by Travis Buttaccio on 6/2/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMLanguagePicker.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface LMLanguagePicker ()

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@end

@implementation LMLanguagePicker

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.picker1.dataSource = self;
    self.picker2.dataSource = self;
    
    self.picker1.delegate = self;
    self.picker2.delegate = self;
    
    [self.continueButton setEnabled:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.continueButton.layer setCornerRadius:10.0];
    [self.continueButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.continueButton.layer setBorderWidth:1.0f];
    [self.continueButton.layer setBackgroundColor:[UIColor lm_tealBlueColor].CGColor];
    [self.continueButton setClipsToBounds:YES];
    
    [self p_renderBackground];
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([self.picker1 selectedRowInComponent:0] == [self.picker2 selectedRowInComponent:0]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh...", @"Uh oh...")
                                                        message:NSLocalizedString(@"Please select different language options", @"select different language options")
                                                       delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if ([self.picker2 selectedRowInComponent:0] == 0 || [self.picker2 selectedRowInComponent:0] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh...", @"Uh oh...")
                                                        message:NSLocalizedString(@"Please make language selections", @"missing language selection")
                                                       delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    [self p_saveUserInfo];
    
    return YES;
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
    return [NSArray lm_languageOptionsFull].count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *rowView = view;
    
    if (!view) {
        rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 50, 50)];
        
        UIImageView *flagView;
        
        if (row != 0) {
            flagView = [[UIImageView alloc] initWithImage:[NSArray lm_countryFlagImages][row]];
            flagView.contentMode = UIViewContentModeScaleAspectFit;
            flagView.frame = CGRectMake(0, 5, 40, 40);
        }
        
        UILabel *tView = (UILabel *)view;
        tView = [[UILabel alloc] init];
        tView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 50, 50);
        [tView setFont:[UIFont lm_noteWorthyLarge]];
        tView.textColor = [UIColor whiteColor];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.numberOfLines = 7;
        tView.text = [NSArray lm_languageOptionsNative][row];
        
        [rowView addSubview:tView];
        [rowView addSubview:flagView];
    }
    
    return rowView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

#pragma mark - UIPickerView Delegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSArray lm_languageOptionsFull][row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.picker1 selectedRowInComponent:0] != - 1 && [self.picker2 selectedRowInComponent:0] != -1) {
        [self.continueButton setEnabled:YES];
    }
}

#pragma mark - Private Methods

-(void) p_saveUserInfo
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving Preferences...";
    [hud show:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    NSInteger selectedNativeLanguage = [_picker1 selectedRowInComponent:0];
    currentUser[PF_USER_FLUENT_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][selectedNativeLanguage] lowercaseString];
    
    NSInteger selectedLearningLanguage = [_picker2 selectedRowInComponent:0];
    currentUser[PF_USER_DESIRED_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][selectedLearningLanguage] lowercaseString];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString lm_parseError:error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            [hud hide:YES afterDelay:1.0];
        }
        
    }];
}

-(void) p_renderBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    _imageLayer = [CALayer layer];
    _imageLayer.contents = (id)[UIImage imageNamed:@"sunrise"].CGImage;
    _imageLayer.contentsGravity = kCAGravityResizeAspectFill;
    _imageLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_imageLayer atIndex:0];
    
    _gradientLayer = [CALayer lm_universalBackgroundColor];
    _gradientLayer.frame = self.view.frame;
    
    [[self.view layer] insertSublayer:_gradientLayer above:_imageLayer];
    [[self.view layer] setShadowColor:[UIColor whiteColor].CGColor];
}

@end
