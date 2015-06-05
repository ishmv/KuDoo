//
//  SelectLanguages.m
//  simplechat
//
//  Created by Travis Buttaccio on 6/2/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "SelectLanguages.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface SelectLanguages ()

@end

@implementation SelectLanguages

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
    [self.continueButton.layer setBackgroundColor:[UIColor lm_orangeColor].CGColor];
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
    return [LMGlobalVariables LMLanguageOptions].count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *tView = (UILabel *)view;
    
    if (!tView) {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont lm_noteWorthyMedium]];
        tView.textColor = [UIColor lm_cloudsColor];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.numberOfLines = 3;
    }
    
    tView.text = [LMGlobalVariables LMLanguageOptions][row];
    return tView;
}

#pragma mark - UIPickerView Delegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [LMGlobalVariables LMLanguageOptions][row];
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
    currentUser[PF_USER_FLUENT_LANGUAGE] = [[LMGlobalVariables LMLanguageOptions][selectedNativeLanguage] lowercaseString];
    
    NSInteger selectedLearningLanguage = [_picker2 selectedRowInComponent:0];
    currentUser[PF_USER_DESIRED_LANGUAGE] = [[LMGlobalVariables LMLanguageOptions][selectedLearningLanguage] lowercaseString];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[LMGlobalVariables parseError:error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            [hud hide:YES afterDelay:1.0];
        }
        
    }];
}

-(void) p_renderBackground
{
    CALayer *imageLayer = [LMGlobalVariables spaceImageBackgroundLayer];
    imageLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:imageLayer atIndex:0];
    
    CALayer *colorLayer = [LMGlobalVariables wetAsphaltWithOpacityBackgroundLayer];
    colorLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:colorLayer above:imageLayer];
}

@end
