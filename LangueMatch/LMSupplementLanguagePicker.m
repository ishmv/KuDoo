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
    UILabel *tView = (UILabel *)view;
    
    if (!tView) {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont lm_noteWorthyMedium]];
        tView.textColor = [UIColor lm_cloudsColor];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.numberOfLines = 3;
    }
    
    tView.text = [NSArray lm_languageOptionsFull][row];
    return tView;
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
