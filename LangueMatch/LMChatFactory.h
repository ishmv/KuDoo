/*
 
 Handles creation of chats on server and handing off to ChatView
 ToDo: Replace with Parse Cloud Code
 
 */


#import <Foundation/Foundation.h>

@class  PFObject;

typedef void (^LMInitiateChatCompletionBlock)(PFObject *chat, NSError *error);
typedef void (^LMFinishedCreatingChatCompletionBlock)(PFObject *chat, NSError *error);
typedef void (^LMFinishedUploadingChatToServer)(BOOL succeeded, NSError *error);

@interface LMChatFactory : NSObject

/*
 
 Class Method:
 Finds a random LangueMatch user from registetered LMUser database and is returned in completion once user is found
 Match is based on users desired and fluent languages
 
 */

+(void) startRandomChatWithCompletion:(LMInitiateChatCompletionBlock)completion;


/*
 
 Class Method:
 Passed in user list should be full list of users - including currently signed in user
 First queries Local Data Store for existing Chats. If none found:
 Creates Local chat with passed in parameters, returns the chat information once the chat is completed
 Chat is not uploaded to Parse until first message is sent. User list must include currentUser
 
 */

+(void) createChatWithUsers:(NSArray *)users andDetails:(NSDictionary *)options withCompletion:(LMFinishedCreatingChatCompletionBlock)completion;



/*
 
 Class Method:
 Uploads chat to Parse server
 
 */

+(void) saveChat:(PFObject *)chat withCompletion:(LMFinishedUploadingChatToServer)completion;

@end