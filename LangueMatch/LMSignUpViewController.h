#import <UIKit/UIKit.h>

@class LMSignUpViewController, PFUser;

@protocol LMSignUpViewControllerDelegate <NSObject>

@optional

-(void) signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user;

@end

@interface LMSignUpViewController : UIViewController

@property (weak, nonatomic) id <LMSignUpViewControllerDelegate> delegate;

@end
