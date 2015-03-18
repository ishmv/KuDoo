#import <UIKit/UIKit.h>

@protocol LMProfileViewDelegate <NSObject>

-(void) didTapProfileImageView:(UIImageView *)view;
-(void) didTapUpdateBioButton:(UIButton *)button;

@end

@interface LMProfileView : UIScrollView

@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, strong) NSString *aboutMeText;
@property (nonatomic, assign) BOOL isCurrentUser;

@property (nonatomic, weak) id <LMProfileViewDelegate> profileViewDelegate;

@end
