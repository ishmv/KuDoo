/*
 
 Main chat controller for LM
 Coordinates between LMMessageModel and LMChatsModel
 
 */

#import "JSQMessagesViewController.h"

@class PFObject;

@interface LMChatViewController : JSQMessagesViewController

-(instancetype) initWithChat:(PFObject *)chat;

@end
