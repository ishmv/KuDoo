#import <UIKit/UIKit.h>

@interface UIFont (ApplicationFonts)

//Light
+(UIFont *) lm_noteWorthyLightTimeStamp;
+(UIFont *) lm_noteWorthySmall;
+(UIFont *) lm_noteWorthyBio;
+(UIFont *) lm_noteWorthyMedium;
+(UIFont *) lm_noteWorthyLarge;

//Bold
+(UIFont *) lm_noteWorthyLargeBold;
+(UIFont *) lm_noteWorthyMediumBold;

// Roboto Regular (Used for Titles)
+(UIFont *) lm_robotoRegular;
+(UIFont *) lm_robotoRegularTitle;
+(UIFont *) lm_robotoRegularForumTitle;
+(UIFont *) lm_robotoRegularLarge;


// Roboto Light (Used for messages - ordered by size)
+(UIFont *) lm_robotoLightTimestamp;
+(UIFont *) lm_robotoLightMessagePreview;
+(UIFont *) lm_robotoLightMessage;
+(UIFont *) lm_robotoLightLarge;

@end
