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
typedef void (^LMFindRandomUserCompletion)(PFUser *user, UIImage *userImage, NSError *error);

@interface LMParseConnection : PFObject

//User Profile Methods
+(void)saveUserLanguageSelection:(LMLanguageChoice)language forType:(LMLanguageChoiceType)type;
+(void)saveUserProfileImage:(UIImage *)image;
+(void)saveUsersUsername:(NSString *)username;


@end
