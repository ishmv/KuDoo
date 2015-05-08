/*

LMParseConnection
Handles all interaction with Parse backend
 
*/

#import "LMGlobalVariables.h"

#import <Parse/Parse.h>

typedef void (^LMFinishedUploadingMessageToServer)(BOOL succeeded, NSError *error);
typedef void (^LMFinishedFetchingObjects)(NSArray *objects, NSError *error);
typedef void (^LMFinishedUserSearch)(NSArray *users, NSError *error);
typedef void (^LMFinishedSendingRequestToUser)(BOOL sent, NSError *error);

@interface LMParseConnection : PFObject

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


//User Friend Methods
+(void) searchUsersWithCriteria:(NSDictionary *)critera withCompletion:(LMFinishedUserSearch)completion;
+(void) getFriendsFromLocalDataStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion;
+(void) getFriendRequestsForCurrentUserWithCompletion:(LMFinishedFetchingObjects)completion;
+(void) addFriendshipRelationWithUser:(PFUser *)user;
+(void) sendUser:(PFUser *)user request:(LMRequestType)request withCompletion:(LMFinishedSendingRequestToUser)completion;
+(void) acceptFriendRequest:(PFObject *)request;


//User Profile Methods
+(void)saveUserLanguageSelection:(LMLanguageChoice)language forType:(LMLanguageChoiceType)type;
+(void)saveUserProfileImage:(UIImage *)image;
+(void)saveUsersUsername:(NSString *)username;


@end
