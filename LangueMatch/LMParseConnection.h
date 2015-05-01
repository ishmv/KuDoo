/*

LMParseConnection
Handles all interaction with Parse backend
 
*/

#import <Parse/Parse.h>

typedef void (^LMFinishedUploadingMessageToServer)(BOOL succeeded, NSError *error);
typedef void (^LMFinishedFetchingChatMessages)(NSArray *messages, NSError *error);

@interface LMParseConnection : PFObject
/*
 
 @abstract: Asynchronously saves the message to server,
            then creates and saves identical messages for each user in the chat
 
 @param:    message     -   is the PFObject to be saved
            completion  -   returns YES if succeeded, or NO if not with corresponding error
 
 @returns: not return value, completion call back
 
 */
+(void) saveMessage:(PFObject *)message withCompletion:(LMFinishedUploadingMessageToServer)completion;

/*
 
 @abstract: Asynchronously grabs the messages for the chat. kPFCachePolicy is KPFCachePolicyCacheThenNetwork
 
 @param: chat is the PFObject to be saved to Parse
 Will be saved under LMChat class.
 
 @returns: Returns YES if save was successfull. Otherwise the corresponding error message
 
 */
+(void) getMessagesForChat:(PFObject *)chat withCompletion:(LMFinishedFetchingChatMessages)completion;

@end
