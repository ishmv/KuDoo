#import <UIKit/UIKit.h>

@class PFUser;

@protocol LMLoginViewDelegate <NSObject>

@optional

-(void) LMUser:(NSString *)username pressedLoginButton:(UIButton *)button withPassword:(NSString *)password;
-(void) userPressedSignUpButton:(UIButton *)button;
-(void) userPressedForgotPasswordButton:(UIButton *)button;

@end

@interface LMLoginView : UIView

@property (nonatomic, weak) id <LMLoginViewDelegate> delegate;

@end
