#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) lm_noteWorthySmall
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:13];
}

+(UIFont *) lm_noteWorthyMedium
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:15];
}

+(UIFont *) lm_noteWorthyLarge
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:22];
}

+(UIFont *) lm_noteWorthyBio
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:14];
}

+(UIFont *) lm_noteWorthyLightTimeStamp
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:9];
}

+(UIFont *) lm_noteWorthyMediumBold
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:16];
}

+(UIFont *) lm_noteWorthyLargeBold
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:20];
}

// Regular

+(UIFont *) lm_robotoRegular
{
    return [UIFont fontWithName:@"Roboto-Regular" size:15];
}

+(UIFont *) lm_robotoRegularTitle
{
    return [UIFont fontWithName:@"Roboto-Regular" size:20];
}


// Light

+(UIFont *) lm_robotoLightTimestamp
{
    return [UIFont fontWithName:@"Roboto-Light" size:10];
}

+(UIFont *) lm_robotoLightMessagePreview
{
    return [UIFont fontWithName:@"Roboto-Light" size:14];
}

+(UIFont *) lm_robotoLightMessage
{
    return [UIFont fontWithName:@"Roboto-Light" size:16];
}

+(UIFont *) lm_robotoLightLarge
{
    return [UIFont fontWithName:@"Roboto-Light" size:20];
}

@end
