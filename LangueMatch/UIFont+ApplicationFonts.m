#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) applicationFontLarge
{
    return [UIFont fontWithName:@"Avenir-Light" size:18];
}

+(UIFont *) applicationFontSmall
{
    return [UIFont fontWithName:@"Avenir-Light" size:12];
}

@end
