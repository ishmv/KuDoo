#import "LMFriendsModel.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendsModel() {
    NSMutableArray *_friendList;
}

@property (strong, nonatomic) NSArray *friendList;

@end

@implementation LMFriendsModel

-(instancetype) init
{
    if (self = [super init]) {
        [self checkServerForFriends];
    }
    return self;
}

/* -- Query local data store since friends were pinned at signup -- */

-(void)checkServerForFriends
{
    if (!_friendList) {
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *friendQuery = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [friendQuery whereKey:PF_USER_OBJECTID equalTo:currentUser.objectId];
        [friendQuery includeKey:PF_USER_FRIENDS];
        
        [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            
            NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
            [PFObject pinAllInBackground:friends];
            
            // LMFriendsListViewController will always have a strong pointer to LMFriendsModel, so no need for weak/strong dance
            [self willChangeValueForKey:@"friendList"];
            self.friendList = friends;
            [self didChangeValueForKey:@"friendList"];
        }];
    }
}

//
//+(NSArray) cachedFriendList
//{
//    PFUser *currentUser = [PFUser currentUser];
//    
//    PFQuery *friendQuery = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//    [friendQuery whereKey:PF_USER_OBJECTID equalTo:currentUser.objectId];
//    [friendQuery includeKey:PF_USER_FRIENDS];
//    [friendQuery fromLocalDatastore];
//    
//    [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
//        
//        NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
//        return friends;
//
//    }];
//}

#pragma mark - Key/Value Observing

-(NSUInteger)countOfFriendList
{
    return self.friendList.count;
}

-(id) objectInFriendListAtIndex:(NSUInteger)index
{
    return [self.friendList objectAtIndex:index];
}

-(NSArray *) friendListAtIndexes:(NSIndexSet *)indexes
{
    return [self.friendList objectsAtIndexes:indexes];
}

-(void) insertObject:(id)object inFriendListAtIndex:(NSUInteger)index
{
    [_friendList insertObject:object atIndex:index];
}

-(void) removeObjectFromFriendListAtIndex:(NSUInteger)index
{
    [_friendList removeObjectAtIndex:index];
}

-(void) replaceObjectInFriendListAtIndex:(NSUInteger)index withObject:(id)object
{
    [_friendList replaceObjectAtIndex:index withObject:object];
}

@end
