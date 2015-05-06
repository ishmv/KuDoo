/*
 
Superclass for displaying user profile content
 
*/

#import <UIKit/UIKit.h>

@class PFUser;

@interface LMUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PFUser *user;

-(instancetype) initWith:(PFUser *)user;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UIImageView *profilePicView;

@end
