#import <UIKit/UIKit.h>

@class QBUUser;

@protocol LMSignUpViewDelegate <NSObject>

@required

@optional
-(void) userPressedSignUpButton:(UIButton *)button withUserCredentials:(QBUUser *)user;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

@end
