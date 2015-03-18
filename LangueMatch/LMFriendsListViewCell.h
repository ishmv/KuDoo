#import <UIKit/UIKit.h>

@class PFUser;

@interface LMFriendsListViewCell : UITableViewCell

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *friendName;
@property (strong, nonatomic) NSString *friendLanguage;

@end
