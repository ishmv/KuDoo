#import <UIKit/UIKit.h>

@protocol LMSignUpViewDelegate <NSObject>

@optional

-(void) userWithCredentials:(NSDictionary *)info pressedSignUpButton:(UIButton *)sender;
-(void) facebookButtonPressed:(UIButton *)sender;
-(void) twitterButtonPressed:(UIButton *)sender;
-(void) hasAccountButtonPressed;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

@property (strong, nonatomic) UILabel *signUpLabel;
@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *haveAccountButton;

@end
