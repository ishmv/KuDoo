#import <UIKit/UIKit.h>

@class QBSessionParameters;

@protocol LMLoginViewDelegate <NSObject>

@required

@optional
-(void) userPressedLoginButton:(UIButton *)button withQBSessionParameters:(QBSessionParameters *)parameters;
-(void) userPressedSignUpButton:(UIButton *)button;

@end

@interface LMLoginView : UIView

@property (nonatomic, weak) id <LMLoginViewDelegate> delegate;

@end
