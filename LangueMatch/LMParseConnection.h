/*

LMParseConnection
Handles all interaction with Parse backend
 
*/

#import <Parse/Parse.h>

typedef void (^LMFinishedUploadingChatToServer)(BOOL succeeded, NSError *error);

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

@end
