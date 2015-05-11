#import <Foundation/Foundation.h>

@class PFUser;

@interface LMFriendsModel : NSObject

+(instancetype) sharedInstance;

@property (strong, nonatomic, readonly) NSArray *friendList;

-(void) addFriend:(PFUser *)user;

@end
