#import <UIKit/UIKit.h>

@class PFUser;

@protocol LMLoginViewDelegate <NSObject>

@required

-(void) PFUser:(PFUser *)user pressedLoginButton:(UIButton *)button;
-(void) userPressedSignUpButton:(UIButton *)button;

@optional

@end

@interface LMLoginView : UIView

@property (nonatomic, weak) id <LMLoginViewDelegate> delegate;

@end
