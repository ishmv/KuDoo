/*
 
Superclass for displaying user profile content
 Should be subclassed
 
*/

#import <UIKit/UIKit.h>

@class PFUser;

@interface LMUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(instancetype) initWith:(PFUser *)user;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end
