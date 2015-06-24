#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) lm_noteWorthySmall
{
    return[UIFont fontWithName:@"Noteworthy-Light" size:13];
}

+(UIFont *) lm_noteWorthyMedium
{
    return[UIFont fontWithName:@"Noteworthy-Bold" size:15];
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

@end
