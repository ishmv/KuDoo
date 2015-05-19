#import <UIKit/UIKit.h>

@class PFUser;

typedef void (^LMCompletedSelectingLanguage)(NSString *language);

@protocol LMSignUpViewDelegate <NSObject>

@required
-(void) pressedFluentLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion;
-(void) pressedDesiredLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion;
-(void) PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button;
-(void) userPressedFacebookButtonWithLanguagePreferences:(NSDictionary *)preferences;
-(void) profileImageViewSelected:(UIImageView *)imageView;
-(void) hasAccountButtonPressed;

@optional

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;
@property (strong, nonatomic) UIImage *profileImage;

@end
