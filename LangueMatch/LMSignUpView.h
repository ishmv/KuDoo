#import <UIKit/UIKit.h>

@class PFUser;

typedef void (^LMCompletedSelectingLanguage)(NSString *language);

@protocol LMSignUpViewDelegate <NSObject>

@required

@optional
-(void) pressedFluentLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion;
-(void) pressedDesiredLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion;
-(void) PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

@end
