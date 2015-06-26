//
//  UITextField+LMTextFields.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/22/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "UITextField+LMTextFields.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"

@implementation UITextField (LMTextFields)

+(UITextField *) lm_defaultTextFieldWithPlaceholder:(NSString *)placeholder
{
    UITextField *textField = ({
        
        UITextField *field = [[UITextField alloc] init];
        
        field.keyboardAppearance = UIKeyboardTypeDefault;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.borderStyle = UITextBorderStyleNone;
        field.placeholder = placeholder;
        field.clearsOnBeginEditing = YES;
        [field setFont:[UIFont lm_robotoLightMessage]];
        field.textColor = [UIColor whiteColor];
        field.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.7f];
        field.textAlignment = NSTextAlignmentLeft;
        [field.layer setBorderColor:[UIColor whiteColor].CGColor];
        [field.layer setCornerRadius:5.0f];
        [field.layer setMasksToBounds:YES];
        
        UIView *usernameLeftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
        usernameLeftView.backgroundColor = [UIColor clearColor];
        [field setLeftViewMode:UITextFieldViewModeAlways];
        [field setLeftView:usernameLeftView];
       
        field;
    });

    return textField;
}

@end
