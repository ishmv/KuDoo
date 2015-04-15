/*
 
 Handles creation of chats on server and handing off to ChatView
 ToDo: Replace with Parse Cloud Code
 
 */


#import <Foundation/Foundation.h>

@class  PFObject;

typedef void (^LMInitiateChatCompletionBlock)(PFObject *chat, NSError *error);

@interface LMChat : NSObject

+(void) startRandomChatWithCompletion:(LMInitiateChatCompletionBlock)completion;
+(void) startChatWithFriends:(NSArray *)friends withChatOptions:(NSDictionary *)options withCompletion:(LMInitiateChatCompletionBlock)completion;

@end