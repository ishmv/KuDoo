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

+(UIFont *) lm_helveticaLarge
{
    return [UIFont fontWithName:@"Chalkduster" size:20];
}

+(UIFont *) lm_helveticaSmall
{
    return [UIFont fontWithName:@"Chalkduster" size:10];
}

@end
