#import <Parse/Parse.h>

#import "NSArray+LanguageOptions.h"

typedef void (^LMFinishedSendingRequestToUser)(BOOL sent, NSError *error);

typedef NS_ENUM(NSInteger, LMUserPicture) {
    LMUserPictureSelf           =   1,
    LMUserPictureBackground     =   2
};

@interface ParseConnection : NSObject

+(void) signupUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;
+(void) loginUser:(NSString *)username withPassword:(NSString *)password withCompletion:(PFUserResultBlock)completion;
+(void) setUserOnlineStatus:(BOOL)online;
+(void) searchUsersForUsername:(NSString *)username withCompletion:(PFArrayResultBlock)completion;
+(void) saveUserLanguageSelection:(LMLanguageSelection)language forType:(LMLanguageSelectionType)type;
+(void) saveUserImage:(UIImage *)image forType:(LMUserPicture)pictureType;
+(void) saveUsersUsername:(NSString *)username;

@end
