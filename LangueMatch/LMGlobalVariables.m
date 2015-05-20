//
//  LMGlobalVariables.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMGlobalVariables.h"
#import "UIColor+applicationColors.h"

@implementation LMGlobalVariables

+(NSArray *) LMLanguageOptions
{
    return @[@"english", @"spanish", @"japanese", @"hindi"];
}

+(NSString *)parseError:(NSError *)error
{
    NSInteger errorCode = error.code;
    
    if (errorCode == TBParseError_AccountAlreadyLinked) return NSLocalizedString(@"Account Already Linked", @"AccountAlreadyLinked");
    if (errorCode == TBParseError_ConnectionFailed) return NSLocalizedString(@"Connection Failed", @"ConnectionFailed");
    if (errorCode == TBParseError_FacebookAccountAlreadyLinked) return NSLocalizedString(@"Facebook account already linked", @"FacebookAccountAlreadyLinked");
    if (errorCode == TBParseError_FacebookIdMissing) return NSLocalizedString(@"Facebook Id Missing", @"FacebookIdMissing");
    if (errorCode == TBParseError_InvalidEmailAddress) return NSLocalizedString(@"Invalid Email Address", @"invalidEmailAddress");
    if (errorCode == TBParseError_InvalidQuery) return NSLocalizedString(@"Invalid Query", @"InvalidQuery");
    if (errorCode == TBParseError_ObjectNotFound) return NSLocalizedString(@"Nothing matches search criteria", @"ObjectNotFound");
    if (errorCode == TBParseError_UserEmailMissing) return NSLocalizedString(@"Email Is Missing", @"UserEmailMissing");
    if (errorCode == TBParseError_UserEmailTaken) return NSLocalizedString(@"Email Is Taken", @"UserEmailTaken");
    if (errorCode == TBParseError_UsernameMissing) return NSLocalizedString(@"Username Missing", @"UsernameMissing");
    if (errorCode == TBParseError_UsernameTaken) return NSLocalizedString(@"Sorry, That Username is already taken. Please try another", @"UsernameTaken");
    if (errorCode == TBParseError_UserPasswordMissing) return NSLocalizedString(@"Password Missing", @"PasswordMissing");
    if (errorCode == TBParseError_UserWithEmailNotFound) return NSLocalizedString(@"Email Is Not Linked to any accounts", @"UserWithEmailNotFound");
    if (errorCode == TBParseError_ValidationError) return NSLocalizedString(@"Unable to Verify", @"ValidationError");
    
    return NSLocalizedString(@"Sorry but we seemed to be lost on this end! Please try again in a little bit", @"WeFuckedUp");
}


+(CALayer *)universalBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.locations = @[@(0.5), @(0.8)];
        layer.colors = @[(id)[UIColor lm_tealBlueColor].CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.7f] .CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.4f].CGColor];
        layer.startPoint = CGPointMake(0.3, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer;
    });
    
    return colorLayer;
}

+(CALayer *)profileBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.colors = @[(id)[UIColor lm_tealColor].CGColor, (id)[[UIColor lm_tealColor] colorWithAlphaComponent:0.5f].CGColor];
        layer.startPoint = CGPointMake(0.3, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer;
    });
    
    return colorLayer;
}

+(CALayer *)chatWindowBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
//        layer.locations = @[@(0.4), @(0.7)];
        layer.contents = (id)[UIImage imageNamed:@"spacePicture.jpg"].CGImage;
//        layer.colors = @[(id)[UIColor lm_blueGreenColor].CGColor, (id)[UIColor lm_orangeColor].CGColor, (id)[UIColor lm_wetAsphaltColor].CGColor];
//        layer.startPoint = CGPointMake(0.4, 0.0);
//        layer.endPoint = CGPointMake(0.5, 1.0);
        layer;
    });
    
    return colorLayer;
}

@end
