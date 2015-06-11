#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "NSString+Chats.h"
#import "AppConstant.h"

#import "NSArray+LanguageOptions.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "CALayer+BackgroundLayers.h"

@interface LMLanguagePicker : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker1;
@property (weak, nonatomic) IBOutlet UIPickerView *picker2;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end