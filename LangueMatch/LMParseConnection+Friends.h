#import "LMParseConnection.h"

@interface LMParseConnection (Friends)

+(void) searchUsersWithCriteria:(NSDictionary *)critera withCompletion:(LMFinishedUserSearch)completion;
+(void) getFriendsFromLocalDataStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion;
+(void) getFriendRequestsForCurrentUserWithCompletion:(LMFinishedFetchingObjects)completion;
+(void) addFriendshipRelationWithUser:(PFUser *)user;
+(void) sendUser:(PFUser *)user request:(LMRequestType)request withCompletion:(LMFinishedSendingRequestToUser)completion;
+(void) acceptFriendRequest:(PFObject *)request;

@end
