#import <UIKit/UIKit.h>

@class PFUser;

@protocol LMProfileViewDelegate <NSObject>

-(void) didTapUpdateBioButton:(UIButton *)button;
-(void) didTapChatButton:(UIButton *)button;

@end

@interface LMProfileView : UIScrollView

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, weak) id <LMProfileViewDelegate> profileViewDelegate;

@end
