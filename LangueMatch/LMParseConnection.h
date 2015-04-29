/*

LMParseConnection
Handles all interaction with Parse backend
 
*/

#import <Parse/Parse.h>

typedef void (^LMFinishedUploadingChatToServer)(BOOL succeeded, NSError *error);
typedef void (^LMFinishedCreatingChatCompletionBlock)(PFObject *chat, NSError *error);

@interface LMParseConnection : PFObject

/*
 
 @abstract: Asynchronously updates a chat to Parse Server for each user in the PF_CHAT_MEMBERS list, each
            user is listed as the PF_CHAT_SENDER for their respective chat.
 
 @param: chat is the PFObject to be saved to Parse
         Will be saved under LMChat class
 
 @returns: Returns a YES BOOL if successful. Otherwise an error message.
            Sends push notification to members of chat
 
*/
+(void) saveChat:(PFObject *)chat withCompletion:(LMFinishedUploadingChatToServer)completion;

/*
 
 @abstract: creates a chat for the currently logged in user [PFUser currentUser] from an existing chat
 
 @param: chat is the groupdId to query against the LMChat database
        Will be saved under LMChat class
 
 @returns: Pins the chat to local data store and is returned to the message Sender
 
 @discussion: This would be used for when a message is received for a new chat, or the user deleted an existing chat from the chats list
 
 */
+(void) createMemberChatFromGroupId:(NSString *)groupId senderId:(NSString *)senderId withCompletion:(LMFinishedCreatingChatCompletionBlock)completion;

@end
