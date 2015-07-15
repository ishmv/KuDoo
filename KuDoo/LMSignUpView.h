@class FBSDKLoginButton;
@import UIKit;

@protocol LMSignUpViewDelegate <NSObject>

@optional

-(void) userWithCredentials:(NSDictionary *)info pressedSignUpButton:(UIButton *)sender;
-(void) facebookButtonPressed:(UIButton *)sender;
-(void) twitterButtonPressed:(UIButton *)sender;
-(void) hasAccountButtonPressed: (UIButton *)sender;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

@property (strong, nonatomic, readonly) UILabel *signUpLabel;
@property (strong, nonatomic, readonly) UILabel *langMatchSlogan;
@property (strong, nonatomic, readonly) UITextField *usernameField;
@property (strong, nonatomic, readonly) UITextField *passwordField;
@property (strong, nonatomic, readonly) UITextField *emailField;
@property (strong, nonatomic, readonly) UIButton *signUpButton;
@property (strong, nonatomic, readonly) FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic, readonly) UIButton *twitterButton;
@property (strong, nonatomic, readonly) UIButton *haveAccountButton;


@property (nonatomic, assign) BOOL alertIsShowing;

@end
