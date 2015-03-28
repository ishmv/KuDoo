#import <UIKit/UIKit.h>

@class PFObject;



@interface LMChatListCell : UITableViewCell

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) UIImage *chatImage;

@end
