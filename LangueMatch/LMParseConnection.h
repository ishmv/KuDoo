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
typedef void (^LMFinishedLoggingInUser)(PFUser *user, NSError *error);

@interface LMParseConnection : PFObject

//User Profile Methods
+(void) signupUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;
+(void) loginUser:(NSString *)username withPassword:(NSString *)password withCompletion:(LMFinishedLoggingInUser)completion;

+(void)saveUserLanguageSelection:(LMLanguageChoice)language forType:(LMLanguageChoiceType)type;
+(void)saveUserImage:(UIImage *)image forType:(LMUserPicture)pictureType;
+(void)saveUsersUsername:(NSString *)username;


@end
