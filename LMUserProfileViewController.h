#import <UIKit/UIKit.h>

@class PFUser;

@interface LMUserProfileViewController : UIViewController

extern NSString *const LMInitiateChatNotification;

@property (nonatomic, strong) PFUser *user;

@end
