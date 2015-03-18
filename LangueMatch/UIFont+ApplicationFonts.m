#import "UIFont+ApplicationFonts.h"

@implementation UIFont (ApplicationFonts)

+(UIFont *) applicationFontLarge
{
    return [UIFont fontWithName:@"ChalkboardSE-Regular" size:18];
}

+(UIFont *) applicationFontSmall
{
    return [UIFont fontWithName:@"ChalkboardSE-Regular" size:12];
}

@end
