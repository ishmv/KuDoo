/*
 
 Presents a list of users friends to choose for chat
 
 */


#import <UIKit/UIKit.h>

typedef void (^LMCompletedFriendSelection)(NSArray *selectedFriends);

@interface LMFriendSelectionViewController : UITableViewController

-(instancetype) initWithCompletion:(LMCompletedFriendSelection)completion;

@end
