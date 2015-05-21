#import "LMParseConnection+Friends.h"
#import "PushNotifications.h"
#import "AppConstant.h"

#import "LMFriendsModel.h"

@implementation LMParseConnection (Friends)

+(void) searchUsersWithCriteria:(NSDictionary *)critera withCompletion:(LMFinishedUserSearch)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    
    
    if (critera[PF_USER_USERNAME]) [query whereKey:PF_USER_USERNAME_LOWERCASE containsString:critera[PF_USER_USERNAME]];
    else if (critera[PF_USER_DESIRED_LANGUAGE]) [query whereKey:PF_USER_DESIRED_LANGUAGE containsString:critera[PF_USER_DESIRED_LANGUAGE]];
    else if (critera[PF_USER_FLUENT_LANGUAGE]) [query whereKey: PF_USER_FLUENT_LANGUAGE containsString:critera[PF_USER_FLUENT_LANGUAGE]];
    
    [query setLimit:20];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        completion(users, error);
    }];
}

+(void)sendUser:(PFUser *)user request:(LMRequestType)request withCompletion:(LMFinishedSendingRequestToUser)completion
{
    switch (request) {
        case LMRequestTypeFriend:
        {
            PFObject *friendRequest = [PFObject objectWithClassName:PF_FRIEND_REQUEST];
            [friendRequest setValue:[PFUser currentUser] forKey:PF_FRIEND_REQUEST_SENDER];
            [friendRequest setValue:user forKey:PF_FRIEND_REQUEST_RECEIVER];
            [friendRequest setValue:@YES forKey:PF_FRIEND_REQUEST_WAITING_RESPONSE];
            
            [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                [PushNotifications sendFriendRequest:friendRequest toUser:user];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FRIEND_REQUEST object:friendRequest];
                completion(succeeded, error);
            }];
            break;
        }
        case LMRequestTypeChat:
            
            NSLog(@"Send Chat Request");
            break;
            
        default:
            NSLog(@"Unrecognized Request");
            break;
    }
}

+(void) acceptFriendRequest:(PFObject *)request
{
    request[PF_FRIEND_REQUEST_WAITING_RESPONSE] = @(NO);
    request[PF_FRIEND_REQUEST_ACCEPTED] = @(YES);
    
    [request saveInBackground];
    
    PFUser *requestUser = request[PF_FRIEND_REQUEST_SENDER];
    PFUser *currentUser = [PFUser currentUser];
    
    PFRelation *relation = [currentUser relationForKey:PF_USER_FRIENDSHIPS];
    [relation addObject:requestUser];
    [currentUser saveInBackground];
    
    [PushNotifications acceptFriendRequest:request];
}

+(void) getFriendRequestsForCurrentUserWithCompletion:(LMFinishedFetchingObjects)completion
{
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *sentFriendRequestsQuery = [PFQuery queryWithClassName:PF_FRIEND_REQUEST];
    [sentFriendRequestsQuery whereKey:PF_FRIEND_REQUEST_SENDER equalTo:currentUser];
    
    PFQuery *receivedFriendRequestQuery = [PFQuery queryWithClassName:PF_FRIEND_REQUEST];
    [receivedFriendRequestQuery whereKey:PF_FRIEND_REQUEST_RECEIVER equalTo:currentUser];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[sentFriendRequestsQuery, receivedFriendRequestQuery]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        
        completion(requests, error);
        
    }];
}

+(void) addFriendshipRelationWithUser:(PFUser *)user
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationForKey:@"friendships"];
    [relation addObject:user];
    [currentUser saveInBackground];
}


+(void) getFriendsFromLocalDataStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion
{
    if (fromDatastore)
    {
        PFQuery *localQuery = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [localQuery fromLocalDatastore];
        [localQuery fromPinWithName:PF_USER_FRIENDSHIPS];
        [localQuery orderByAscending:PF_USER_USERNAME];
        
        [localQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
            completion(friends, error);
        }];
    }
    else
    {
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *relation = [currentUser relationForKey:PF_USER_FRIENDSHIPS];
        PFQuery *friendQuery = [relation query];
        [friendQuery orderByAscending:PF_USER_USERNAME];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
            completion(friends, error);
        }];
    }
}


@end
