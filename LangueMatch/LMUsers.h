#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PFUser, UIImage;

typedef void (^LMFindRandomUserCompletion)(PFUser *user, NSError *error);

@interface LMUsers : NSObject

+(instancetype)sharedInstance;

-(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion;
-(void)saveUserProfileImage:(UIImage *)image;


@end
