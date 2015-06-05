#import "LMGlobalVariables.h"
#import "UIColor+applicationColors.h"

@implementation LMGlobalVariables

+(NSArray *) LMLanguageOptions
{
    return @[@"", NSLocalizedString(@"Mandarin (官話/官话)",@"Mandarin (官話/官话)"), NSLocalizedString(@"Spanish (Español)",@"Spanish (Español)"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"Hindi (हिन्दी)", @"Hindi (हिन्दी)"),
             NSLocalizedString(@"Arabic (العربيَّة)", @"Arabic (العربيَّة)"), NSLocalizedString(@"Portuguese (Português)",@"Portuguese (Português)"), NSLocalizedString(@"Bengali (বাংলা)", @"Bengali (বাংলা)"), NSLocalizedString(@"Russian (Русский)",@"Russian (Русский)"),
             NSLocalizedString(@"Japanese (日本語)",@"Japanese (日本語)"), NSLocalizedString(@"Punjabi (ਪੰਜਾਬੀ)", @"Punjabi (ਪੰਜਾਬੀ)"), NSLocalizedString(@"German (Deutsch)", @"German (Deutsch)"),
             NSLocalizedString(@"French (Français)", @"French (Français)"), NSLocalizedString(@"Italian (Italiano)", @"Italian (Italiano)")];
}

+(NSArray *) LMLanguageOptionsNative
{
    return @[@"", NSLocalizedString(@"官話/官话",@"官話/官话"), NSLocalizedString(@"Español",@"Español"), NSLocalizedString(@"English",@"English"), NSLocalizedString(@"हिन्दी", @"हिन्दी"),
             NSLocalizedString(@"العربيَّة", @"العربيَّة"), NSLocalizedString(@"Português",@"Português"), NSLocalizedString(@"বাংলা", @"বাংলা"), NSLocalizedString(@"Русский",@"Русский"),
             NSLocalizedString(@"日本語",@"日本語"), NSLocalizedString(@"ਪੰਜਾਬੀ", @"ਪੰਜਾਬੀ"), NSLocalizedString(@"Deutsch", @"Deutsch"),
             NSLocalizedString(@"Français", @"Français"), NSLocalizedString(@"Italiano", @"Italiano")];
}

+(NSString *)parseError:(NSError *)error
{
    NSInteger errorCode = error.code;
    
    if (errorCode == TBParseError_ConnectionFailed) return NSLocalizedString(@"This is embarrasing but our servers seem to be down. Our apologies for the inconvenience", @"ConnectionFailed");
    if (errorCode == TBParseError_AccountAlreadyLinked) return NSLocalizedString(@"Account Already Linked", @"AccountAlreadyLinked");
    if (errorCode == TBParseError_ConnectionFailed) return NSLocalizedString(@"Connection Failed", @"ConnectionFailed");
    if (errorCode == TBParseError_FacebookAccountAlreadyLinked) return NSLocalizedString(@"Facebook account already linked", @"FacebookAccountAlreadyLinked");
    if (errorCode == TBParseError_FacebookIdMissing) return NSLocalizedString(@"Facebook Id Missing", @"FacebookIdMissing");
    if (errorCode == TBParseError_InvalidEmailAddress) return NSLocalizedString(@"Invalid Email Address", @"invalidEmailAddress");
    if (errorCode == TBParseError_InvalidQuery) return NSLocalizedString(@"Invalid Query", @"InvalidQuery");
    if (errorCode == TBParseError_ObjectNotFound) return NSLocalizedString(@"Nothing matches search criteria", @"ObjectNotFound");
    if (errorCode == TBParseError_UserEmailMissing) return NSLocalizedString(@"Email Is Missing", @"UserEmailMissing");
    if (errorCode == TBParseError_UserEmailTaken) return NSLocalizedString(@"Email Is Taken", @"UserEmailTaken");
    if (errorCode == TBParseError_UsernameMissing) return NSLocalizedString(@"Username Missing", @"UsernameMissing");
    if (errorCode == TBParseError_UsernameTaken) return NSLocalizedString(@"Sorry, That Username is already taken. Please try another", @"UsernameTaken");
    if (errorCode == TBParseError_UserPasswordMissing) return NSLocalizedString(@"Password Missing", @"PasswordMissing");
    if (errorCode == TBParseError_UserWithEmailNotFound) return NSLocalizedString(@"Email Is Not Linked to any accounts", @"UserWithEmailNotFound");
    if (errorCode == TBParseError_ValidationError) return NSLocalizedString(@"Unable to Verify", @"ValidationError");
    
    return NSLocalizedString(@"Sorry but we seemed to be lost on this end! Please try again in a little bit", @"WeFuckedUp");
}


+(CALayer *)universalBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.locations = @[@(0.5), @(0.8)];
        layer.colors = @[(id)[UIColor lm_tealBlueColor].CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.7f] .CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.4f].CGColor];
        layer.startPoint = CGPointMake(0.3, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer;
    });
    
    return colorLayer;
}

+ (CALayer *) wetAsphaltWithOpacityBackgroundLayer
{
    CALayer *layer = ({
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor lm_wetAsphaltColor].CGColor;
        layer.opacity = 0.95f;
        layer;
    });
    
    return layer;
}

+ (CALayer *) spaceImageBackgroundLayer
{
    CALayer *imageLayer = ({
        CALayer *layer = [CALayer layer];
        layer.contents = (id)[UIImage imageNamed:@"spacePicture2.jpg"].CGImage;
        layer.contentsGravity = kCAGravityCenter;
        layer;
    });

    return imageLayer;
}

+(CALayer *)chatWindowBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.contents = (id)[UIImage imageNamed:@"spacePicture.jpg"].CGImage;
        layer;
    });
    
    return colorLayer;
}

@end
