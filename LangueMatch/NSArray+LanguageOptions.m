//
//  NSArray+LanguageOptions.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "NSArray+LanguageOptions.h"

#import <UIKit/UIKit.h>

@implementation NSArray (LanguageOptions)

+(NSArray *) lm_languageOptionsFull
{
    return @[@"", NSLocalizedString(@"Mandarin (官話)",@"Mandarin (官話)"), NSLocalizedString(@"Spanish (Español)",@"Spanish (Español)"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"Hindi (हिन्दी)", @"Hindi (हिन्दी)"),
             NSLocalizedString(@"Arabic (العربيَّة)", @"Arabic (العربيَّة)"), NSLocalizedString(@"Portuguese (Português)",@"Portuguese (Português)"), NSLocalizedString(@"Bengali (বাংলা)", @"Bengali (বাংলা)"), NSLocalizedString(@"Russian (Русский)",@"Russian (Русский)"),
             NSLocalizedString(@"Japanese (日本語)",@"Japanese (日本語)"), NSLocalizedString(@"Punjabi (ਪੰਜਾਬੀ)", @"Punjabi (ਪੰਜਾਬੀ)"), NSLocalizedString(@"German (Deutsch)", @"German (Deutsch)"),
             NSLocalizedString(@"French (Français)", @"French (Français)"), NSLocalizedString(@"Italian (Italiano)", @"Italian (Italiano)")];
}

+(NSArray *) lm_languageOptionsEnglish
{
    return @[@"", NSLocalizedString(@"Mandarin",@"Mandarin"), NSLocalizedString(@"Spanish",@"Spanish"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"Hindi", @"Hindi"),
             NSLocalizedString(@"Arabic", @"Arabic"), NSLocalizedString(@"Portuguese",@"Portuguese"), NSLocalizedString(@"Bengali", @"Bengali"), NSLocalizedString(@"Russian",@"Russian"),
             NSLocalizedString(@"Japanese",@"Japanese"), NSLocalizedString(@"Punjabi", @"Punjabi"), NSLocalizedString(@"German", @"German"),
             NSLocalizedString(@"French", @"French"), NSLocalizedString(@"Italian", @"Italian")];
}

+(NSArray *) lm_languageOptionsNative
{
    return @[@"", NSLocalizedString(@"官話",@"官話"), NSLocalizedString(@"Español",@"Español"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"हिन्दी", @"हिन्दी"),
             NSLocalizedString(@"العربيَّة", @"العربيَّة"), NSLocalizedString(@"Português",@"Português"), NSLocalizedString(@"বাংলা", @"বাংলা"), NSLocalizedString(@"Русский",@"Русский"),
             NSLocalizedString(@"日本語",@"日本語"), NSLocalizedString(@"ਪੰਜਾਬੀ", @"ਪੰਜਾਬੀ"), NSLocalizedString(@"Deutsch", @"Deutsch"),
             NSLocalizedString(@"Français", @"Français"), NSLocalizedString(@"Italiano", @"Italiano")];
}

+(NSArray *) lm_countryFlagImages
{
    return @[@"", [UIImage imageNamed:@"china"], [UIImage imageNamed:@"spain"], [UIImage imageNamed:@"england"], [UIImage imageNamed:@"india"], [UIImage imageNamed:@"egypt"], [UIImage imageNamed:@"portugal"], [UIImage imageNamed:@"india"], [UIImage imageNamed:@"russia"], [UIImage imageNamed:@"japan"], [UIImage imageNamed:@"bangladesh"], [UIImage imageNamed:@"germany"],[UIImage imageNamed:@"france"], [UIImage imageNamed:@"italy"]];
}

+(NSArray *) lm_chatBackgroundImages
{
    return @[[UIImage imageNamed:@"defaultChatWallpaper"], [UIImage imageNamed:@"dropsOfWater"], [UIImage imageNamed:@"auroraBorealis"], [UIImage imageNamed:@"trippy"], [UIImage imageNamed:@"space"], [UIImage imageNamed:@"austin2"], [UIImage imageNamed:@"dessertSunset"], [UIImage imageNamed:@"sunrise"], [UIImage imageNamed:@"austin1"]];
}

@end
