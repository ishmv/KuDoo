//
//  LMSupplementLanguagePicker.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSupplementLanguagePicker.h"

@interface LMSupplementLanguagePicker ()

@end

@implementation LMSupplementLanguagePicker

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSInteger secondLanguageChoice = [self.picker1 selectedRowInComponent:0];
    NSString *secondLanguage = [NSArray lm_languageOptionsFull][secondLanguageChoice];
    NSString *nativeLanguage = [PFUser currentUser][PF_USER_FLUENT_LANGUAGE];
    
    if ([[secondLanguage lowercaseString] isEqualToString:nativeLanguage]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh...", @"Uh oh...")
                                                        message:NSLocalizedString(@"This is the same as your native language", @"select different language options")
                                                       delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    NSInteger thirdLanguageChoice = [self.picker2 selectedRowInComponent:0];
    NSString *thirdLanguage = [NSArray lm_languageOptionsFull][thirdLanguageChoice];
    
    if ([[thirdLanguage lowercaseString] isEqualToString:nativeLanguage]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh...", @"Uh oh...")
                                                        message:NSLocalizedString(@"This is the same as your native", @"missing language selection")
                                                       delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    [self p_saveUserInfo];
    
    return YES;
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

#pragma mark - Private Methods

-(void) p_saveUserInfo
{
    PFUser *currentUser = [PFUser currentUser];
    NSInteger secondLanguage = [self.picker1 selectedRowInComponent:0];
    currentUser[PF_USER_FLUENT_LANGUAGE2] = [[NSArray lm_languageOptionsFull][secondLanguage] lowercaseString];
    
    NSInteger thirdLanguage = [self.picker2 selectedRowInComponent:0];
    currentUser[PF_USER_FLUENT_LANGUAGE3] = [[NSArray lm_languageOptionsFull][thirdLanguage] lowercaseString];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString lm_parseError:error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
}


@end
