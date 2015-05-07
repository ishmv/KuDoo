#import "LMFriendRequestModel.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendRequestModel() {
    NSMutableArray *_friendRequests;
}

@property (strong, nonatomic) NSArray *friendRequests;

@end

@implementation LMFriendRequestModel

-(instancetype) init
{
    if (self = [super init])
    {
        [self checkServerForFriendRequests];
    }
    return self;
}

/* -- Query local data store since friends were pinned at signup -- */


-(void) checkServerForFriendRequests
{
    if (!_friendRequests) {
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *friendRequestsQuery = [PFQuery queryWithClassName:PF_USER_FRIEND_REQUEST];
        [friendRequestsQuery whereKey:PF_FRIEND_REQUEST equalTo:currentUser];
        [friendRequestsQuery includeKey:PF_FRIEND_REQUEST_SENDER];

        [friendRequestsQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
            
            [PFObject pinAllInBackground:requests];
            
            // LMListViewController will always have a strong pointer to LMFriendsModel, so no need for weak/strong dance
            [self willChangeValueForKey:@"friendRequests"];
            self.friendRequests = requests;
            [self didChangeValueForKey:@"friendRequests"];
        }];
    }
}

-(void) addFriendRequestsObject:(PFObject *)object
{
    NSMutableArray *mutableArrayForKVO = [self mutableArrayValueForKey:@"friendRequests"];
    [mutableArrayForKVO insertObject:object atIndex:0];
}

#pragma mark - Key/Value Observing

-(NSUInteger)countOfFriendRequests
{
    return self.friendRequests.count;
}

-(id) objectInFriendRequestsAtIndex:(NSUInteger)index
{
    return [self.friendRequests objectAtIndex:index];
}

-(NSArray *) friendRequestsAtIndexes:(NSIndexSet *)indexes
{
    return [self.friendRequests objectsAtIndexes:indexes];
}

-(void) insertObject:(id)object inFriendRequestsAtIndex:(NSUInteger)index
{
    [_friendRequests insertObject:object atIndex:index];
}

-(void) removeObjectFromFriendRequestsAtIndex:(NSUInteger)index
{
    [_friendRequests removeObjectAtIndex:index];
}

-(void) replaceObjectInFriendRequestsAtIndex:(NSUInteger)index withObject:(id)object
{
    [_friendRequests replaceObjectAtIndex:index withObject:object];
}

@end