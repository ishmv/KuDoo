/*

LMParseConnection
Handles all interaction with Parse backend
 
*/

#import <Parse/Parse.h>

typedef void (^LMFinishedUploadingChatToServer)(BOOL succeeded, NSError *error);
typedef void (^LMFinishedUploadingMessageToServer)(BOOL succeeded, NSError *error);
typedef void (^LMFinishedFetchingChatMessages)(NSArray *messages, NSError *error);

@interface LMParseConnection : PFObject
/*
 
 @abstract: Asynchronously updates a chat to Parse Server for each user in the PF_CHAT_MEMBERS list, each
 user is listed as the PF_CHAT_SENDER for their respective chat. Once saved, a push notification
 is sent to each user
 
 @param: chat is the PFObject to be saved to Parse
 Will be saved under LMChat class.
 
 @returns: Returns YES if save was successfull. Otherwise the corresponding error message
 
 */
+(void) saveMessage:(PFObject *)message withCompletion:(LMFinishedUploadingMessageToServer)completion;

/*
 
 @abstract: Asynchronously updates a chat to Parse Server for each user in the PF_CHAT_MEMBERS list, each
 user is listed as the PF_CHAT_SENDER for their respective chat. Once saved, a push notification
 is sent to each user
 
 @param: chat is the PFObject to be saved to Parse
 Will be saved under LMChat class.
 
 @returns: Returns YES if save was successfull. Otherwise the corresponding error message
 
 */
+(void) getMessagesForChat:(PFObject *)chat withCompletion:(LMFinishedFetchingChatMessages)completion;

@end
