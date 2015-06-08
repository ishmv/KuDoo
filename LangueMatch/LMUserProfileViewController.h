/*
 
 Superclass for displaying user profile content
 Should be subclassed
 
 */

#import <UIKit/UIKit.h>

@class PFUser;

@interface LMUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(instancetype) initWithUser:(PFUser *)user;
-(instancetype) initWithUserId:(NSString *)userId;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end