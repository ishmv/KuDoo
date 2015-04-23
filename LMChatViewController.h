/*
 
 Main chat controller for LM
 Coordinates between LMMessageModel and LMChatsModel
 
 */

#import "JSQMessagesViewController.h"

@class PFObject;

/*
 
 Method called when user pressed back button in active chat
 Can be used to delete chat in model if no messages were sent - 'false start'
 
 */

@protocol LMChatViewControllerDelegate <NSObject>

-(void) userEndedChat:(PFObject *)chat;

@end

@interface LMChatViewController : JSQMessagesViewController

-(instancetype) initWithChat:(PFObject *)chat;

@property (nonatomic, weak) id <LMChatViewControllerDelegate> delegate;

@end
