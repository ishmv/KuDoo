#import <Foundation/Foundation.h>

@class PFUser;

typedef void (^LMFindRandomUserCompletion)(PFUser *user, NSError *error);

@interface LMUsers : NSObject

+(instancetype)sharedInstance;

-(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion;

@end
