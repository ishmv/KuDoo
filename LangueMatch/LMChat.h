/*
 
 --- LMChat.h ---
 
 Handles creation of chats on server and handing off to ChatView
 
 */


// ToDo combine with LMUser to find random person for chat

#import <Foundation/Foundation.h>
@class PFUser;

@class  LMChat, PFObject;

typedef void (^LMInitiateChatCompletionBlock)(PFObject *chat, NSError *error);

@interface LMChat : NSObject

+ (instancetype) sharedInstance;

-(void) startChatWithRandomUser:(PFUser *)user completion:(LMInitiateChatCompletionBlock)completion;
-(void) startChatWithUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion;

@end