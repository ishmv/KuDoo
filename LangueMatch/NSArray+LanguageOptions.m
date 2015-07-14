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
    return @[@"", @"官話 (Mandarin)", @"Español (Spanish)",@"English", @"हिन्दी (Hindi)",
             @"(Arabic) العربيَّة", @"Português (Portuguese)", @"Русский (Russian)",
             @"日本語 (Japanese)", @"Deutsch (German)", @"한국어 (Korean)",
             @"Français (French)", @"Italiano (Italian)"];
}

//+(NSArray *) lm_languageOptionsFull
//{
//    return @[@"", NSLocalizedString(@"Mandarin (官話)",@"Mandarin (官話)"), NSLocalizedString(@"Spanish (Español)",@"Spanish (Español)"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"Hindi (हिन्दी)", @"Hindi (हिन्दी)"),
//             NSLocalizedString(@"Arabic (العربيَّة)", @"Arabic (العربيَّة)"), NSLocalizedString(@"Portuguese (Português)",@"Portuguese (Português)"), NSLocalizedString(@"Bengali (বাংলা)", @"Bengali (বাংলা)"), NSLocalizedString(@"Russian (Русский)",@"Russian (Русский)"),
//             NSLocalizedString(@"Japanese (日本語)",@"Japanese (日本語)"), NSLocalizedString(@"Punjabi (ਪੰਜਾਬੀ)", @"Punjabi (ਪੰਜਾਬੀ)"), NSLocalizedString(@"German (Deutsch)", @"German (Deutsch)"),
//             NSLocalizedString(@"French (Français)", @"French (Français)"), NSLocalizedString(@"Italian (Italiano)", @"Italian (Italiano)"), ];
//}


+(NSArray *) lm_languageOptionsEnglish
{
    return @[@"", @"Mandarin", @"Spanish", @"English", @"Hindi", @"Arabic" ,@"Portuguese", @"Russian", @"Japanese", @"German",@"Korean", @"French", @"Italian"];
}
//
//+(NSArray *) lm_languageOptionsEnglish
//{
//    return @[@"", NSLocalizedString(@"Mandarin",@"Mandarin"), NSLocalizedString(@"Spanish",@"Spanish"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"Hindi", @"Hindi"),
//             NSLocalizedString(@"Arabic", @"Arabic"), NSLocalizedString(@"Portuguese",@"Portuguese"), NSLocalizedString(@"Bengali", @"Bengali"), NSLocalizedString(@"Russian",@"Russian"),
//             NSLocalizedString(@"Japanese",@"Japanese"), NSLocalizedString(@"Punjabi", @"Punjabi"), NSLocalizedString(@"German", @"German"),
//             NSLocalizedString(@"French", @"French"), NSLocalizedString(@"Italian", @"Italian")];
//}

+(NSArray *) lm_languageOptionsNative
{
    return @[@"", @"官話", @"Español", @"English", @"हिन्दी", @"العربيَّة", @"Português", @"Русский", @"日本語", @"Deutsch", @"한국어", @"Français", @"Italiano"];
}

//+(NSArray *) lm_languageOptionsNative
//{
//    return @[@"", NSLocalizedString(@"官話",@"官話"), NSLocalizedString(@"Español",@"Español"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"हिन्दी", @"हिन्दी"),
//             NSLocalizedString(@"العربيَّة", @"العربيَّة"), NSLocalizedString(@"Português",@"Português"), NSLocalizedString(@"বাংলা", @"বাংলা"), NSLocalizedString(@"Русский",@"Русский"),
//             NSLocalizedString(@"日本語",@"日本語"), NSLocalizedString(@"ਪੰਜਾਬੀ", @"ਪੰਜਾਬੀ"), NSLocalizedString(@"Deutsch", @"Deutsch"),
//             NSLocalizedString(@"Français", @"Français"), NSLocalizedString(@"Italiano", @"Italiano")];
//}

+(NSArray *) lm_countryFlagImages
{
    return @[@"", [UIImage imageNamed:@"china"], [UIImage imageNamed:@"spain"], [UIImage imageNamed:@"england"], [UIImage imageNamed:@"india"], [UIImage imageNamed:@"egypt"], [UIImage imageNamed:@"portugal"], [UIImage imageNamed:@"russia"], [UIImage imageNamed:@"japan"], [UIImage imageNamed:@"germany"], [UIImage imageNamed:@"korea"], [UIImage imageNamed:@"france"], [UIImage imageNamed:@"italy"]];
}

+(NSArray *) lm_countryBackgroundImages
{
    return @[@"", [UIImage imageNamed:@"chinaBackground"], [UIImage imageNamed:@"spainBackground"], [UIImage imageNamed:@"englandBackground"], [UIImage imageNamed:@"indiaBackground"], [UIImage imageNamed:@"egyptBackground"], [UIImage imageNamed:@"portugalBackground"], [UIImage imageNamed:@"russiaBackground"], [UIImage imageNamed:@"japanBackground"], [UIImage imageNamed:@"germanyBackground"],[UIImage imageNamed:@"koreaBackground"], [UIImage imageNamed:@"franceBackground"], [UIImage imageNamed:@"italyBackground"], ];
}

+(NSArray *) lm_nativeSpeakers
{
    return @[[NSNumber numberWithInt:0], [NSNumber numberWithInt:955], [NSNumber numberWithInt:405], [NSNumber numberWithInt:360], [NSNumber numberWithInt:310], [NSNumber numberWithInt:295], [NSNumber numberWithInt:215], [NSNumber numberWithInt:155], [NSNumber numberWithInt:125], [NSNumber numberWithInt:89],[NSNumber numberWithInt:76], [NSNumber numberWithInt:74], [NSNumber numberWithInt:59]];
}

+(NSArray *) lm_chatBackgroundImages
{
    return @[[UIImage imageNamed:@"defaultChatWallpaper"], [UIImage imageNamed:@"dropsOfWater"], [UIImage imageNamed:@"auroraBorealis"], [UIImage imageNamed:@"trippy"], [UIImage imageNamed:@"space"], [UIImage imageNamed:@"austin2"], [UIImage imageNamed:@"dessertSunset"], [UIImage imageNamed:@"sunrise"], [UIImage imageNamed:@"austin1"]];
}

@end
