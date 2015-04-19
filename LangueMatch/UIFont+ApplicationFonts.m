#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) lm_applicationFontLarge
{
    return [UIFont fontWithName:@"Avenir-Light" size:18];
}

+(UIFont *) lm_applicationFontSmall
{
    return [UIFont fontWithName:@"Avenir-Light" size:12];
}

@end
