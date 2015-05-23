//
//  LMParseConnection+Chats.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMParseConnection.h"

@interface LMParseConnection (Chats)

/*!
 
 @abstract: Asynchronously saves the message to server,
 then creates and saves identical messages for each user in the chat
 
 @param:    message     -   is the PFObject to be saved
 completion  -   returns YES if succeeded, or NO if not with corresponding error
 
 @returns: void
 
 @completion: BOOL indicating operation success, or NSError if there was a problem
 
 */
+(void) saveMessage:(PFObject *)message withCompletion:(LMFinishedUploadingMessageToServer)completion;

/*!
 
 @abstract: Asynchronously grabs the messages for the chat from Parse server
 
 @param: chat is the PFObject to be saved to Parse
 Will be saved under LMChat class.
 
 @returns: void
 
 @completion: Returns corresponding chat messages, otherwise NSError if problem
 
 */
+(void) getMessagesForChat:(PFObject *)chat fromDatasStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion;

/*!
 
 @abstract: Asynchronously fetches users from Parse User databse with provided search criteria
 
 @param: criteria can include 'desired language', 'fluent language', 'username'
 
 @returns: void
 
 @completion: Returns corresponding chat messages, otherwise NSError if problem
 
 */

// Chat methods
+(void) getChatsFromLocalDataStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion;


+(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion;

+(void) sendTypingNotificationForChat:(PFObject *)chat currentlyTyping:(BOOL)typing;

@end
