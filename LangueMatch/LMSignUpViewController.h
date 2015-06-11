#import <UIKit/UIKit.h>
#import "LMSignUpView.h"

@class LMSignUpViewController, PFUser;

@protocol LMSignUpViewControllerDelegate <NSObject>

@optional

-(void) signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user;

@end

@interface LMSignUpViewController : UIViewController <LMSignUpViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) id <LMSignUpViewControllerDelegate> delegate;

@end
