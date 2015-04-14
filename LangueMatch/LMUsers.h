/*
 
 
 This class handles saving all user changes to Parse
 
 */

#import "AppConstant.h"
#import "LMGlobalVariables.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PFUser;

typedef void (^LMFindRandomUserCompletion)(PFUser *user, NSError *error);
typedef void (^LMChatRequestResponseCompletion)(BOOL response);

@interface LMUsers : NSObject

//Move to LMChat Class
+(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion;
+(void)saveUserLanguageSelection:(LMLanguageChoice)language forType:(LMLanguageChoiceType)type;
+(void)saveUserProfileImage:(UIImage *)image;
+(void)saveUsersUsername:(NSString *)username;

@end
