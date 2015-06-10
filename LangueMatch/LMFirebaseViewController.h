/*
 
 Superclass for displaying data in firebase location in table view
 
*/

#import <UIKit/UIKit.h>

@interface LMFirebaseViewController : UITableViewController

-(instancetype) initWithFirebase:(NSString *)path;

@property (copy, nonatomic) NSString *firebasePath;
@property (strong, nonatomic, readonly) NSDictionary *allRequests;

@end
