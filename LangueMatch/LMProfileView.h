#import <UIKit/UIKit.h>
#import "AppConstant.h"
#import "LMGlobalVariables.h"

@class PFUser;

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithSelection)(NSString *language);

@protocol LMProfileViewDelegate <NSObject>

@required

@optional
/* -- For current user --*/
-(void) changeLanguageType:(LMLanguageChoiceType)type withCompletion:(LMCompletedWithSelection)completion;
-(void) changeUsernameWithCompletion:(LMCompletedWithUsername)completion;

/* -- For other LM user --*/
-(void) didTapChatButton:(UIButton *)button;

@end

@interface LMProfileView : UIScrollView

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, weak) id <LMProfileViewDelegate> profileViewDelegate;

@end
