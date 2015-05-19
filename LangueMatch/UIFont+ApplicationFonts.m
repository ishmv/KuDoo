#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) lm_applicationFontLarge
{
    return [UIFont fontWithName:@"Avenir-Light" size:20];
}

+(UIFont *) lm_applicationFontSmall
{
    return [UIFont fontWithName:@"Avenir-Light" size:14];
}

+(UIFont *) lm_chalkdusterLarge
{
    return [UIFont fontWithName:@"Chalkduster" size:22];
}

+(UIFont *) lm_chalkdusterSmall
{
    return [UIFont fontWithName:@"Chalkduster" size:10];
}

+(UIFont *) lm_chalkdusterTitle
{
    return [UIFont fontWithName:@"Chalkduster" size:40];
}


+(UIFont *) lm_chalkboardSELightSmall
{
    return[UIFont fontWithName:@"ChalkboardSE-Light" size:12];
}

+(UIFont *) lm_chalkboardSELightLarge
{
    return[UIFont fontWithName:@"ChalkboardSE-Light" size:22];
}

+(UIFont *) lm_chalkboardSELightTitle
{
    return[UIFont fontWithName:@"ChalkboardSE-Light" size:40];
}

+(UIFont *) lm_noteWorthySmall
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:11];
}

+(UIFont *) lm_noteWorthyMedium
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:16];
}

+(UIFont *) lm_noteWorthyLarge
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:24];
}


+(UIFont *) lm_noteWorthyLightTimeStamp
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:9];
}


@end
