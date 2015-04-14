/*
 
 Presents a list of users friends to choose for chat
 
 */


#import <UIKit/UIKit.h>

typedef void (^LMCompletedFriendSelection)(NSArray *friends);

@interface LMFriendSelectionViewController : UITableViewController

-(instancetype) initWithStyle: (UITableViewStyle)style withCompletion:(LMCompletedFriendSelection)friends;

@end
