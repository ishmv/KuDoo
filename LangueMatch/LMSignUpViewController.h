#import <UIKit/UIKit.h>
#import "LMSignUpView.h"

typedef NS_ENUM(NSInteger, socialMedia) {
    socialMediaNone,
    socialMediaFacebook,
    socialMediaTwitter
};

@class LMSignUpViewController, PFUser;

@protocol LMSignUpViewControllerDelegate <NSObject>

@optional

-(void) signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user withSocialMedia:(socialMedia)social;

@end

@interface LMSignUpViewController : UIViewController <LMSignUpViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) id <LMSignUpViewControllerDelegate> delegate;

@end
