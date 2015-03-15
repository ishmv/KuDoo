#import <UIKit/UIKit.h>

@class PFUser;

@protocol LMSignUpViewDelegate <NSObject>

@required

@optional
-(void) PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

@end
