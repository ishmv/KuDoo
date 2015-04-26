/*
 
 Handles creation of chats on server and handing off to ChatView
 ToDo: Replace with Parse Cloud Code
 
 */


#import <Foundation/Foundation.h>

@class  PFObject, PFUser;

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
 
 @abstract: Synchronously creates a PFObject under class name LMChat if one does not already exist in the local data store. Creates unique groupId to be found on Server
 
 @param: user - will be set as the chat "sender"
         members - these are the other members of the chat - can include user in array, will filter list.
         chatDetails - Used for setting chat details such as title, picture and random BOOL. If 2 person chat, title and picture are set based on the passed in member.
                        If no details are passed in for group chat, default chat picture and titles are set.
 
 @returns: Returns the PFObject or error if there were problems with creation
 
 */
+(void) createChatForUser:(PFUser *)user withMembers:(NSArray *)members chatDetails:(NSDictionary *)details andCompletion:(LMFinishedCreatingChatCompletionBlock)completion;


@end