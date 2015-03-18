#import <UIKit/UIKit.h>

@class PFObject;

@interface LMChatViewCell : UITableViewCell

@property (strong, nonatomic) PFObject *message;

@end
