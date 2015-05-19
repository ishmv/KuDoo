#import "LMTableViewCell.h"

@class PFObject;

@interface LMChatListCell : LMTableViewCell

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) PFObject *lastMessage;

@end
