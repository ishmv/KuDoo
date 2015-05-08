#import "LMFriendsModel.h"
#import "AppConstant.h"
#import "LMParseConnection.h"

#import <Parse/Parse.h>

@interface LMFriendsModel() {
    NSMutableArray *_friendList;
}

@property (strong, nonatomic) NSArray *friendList;

@end

@implementation LMFriendsModel

-(instancetype) init
{
    if (self = [super init])
    {
        [self checkLocalDataStoreForFriends];
    }
    return self;
}

-(void) checkLocalDataStoreForFriends
{
    if (!_friendList)
    {
        [LMParseConnection getFriendsFromLocalDataStore:YES withCompletion:^(NSArray *friends, NSError *error) {
            
            [self willChangeValueForKey:@"friendList"];
            self.friendList = friends;
            [self didChangeValueForKey:@"friendList"];
            
            // First check if network connection is available
            [self checkServerForFriends];
        }];
    }
}

-(void) checkServerForFriends
{
    [LMParseConnection getFriendsFromLocalDataStore:NO withCompletion:^(NSArray *friends, NSError *error) {
        if (!error) {
            for (PFUser *user in friends)
            {
                if (![_friendList containsObject:user])
                {
                    [user pinInBackgroundWithName:@"friends"];
                    [self addFriend:user];
                }
            }
        }
        else if (error)
        {
            NSLog(@"Could not connect to Parse server to retreive friends");
        }
    }];
}

-(void) addFriend:(PFUser *)user
{
    if (![self.friendList containsObject:user]) {
        __block NSUInteger index;
        
        NSUInteger pass = [self.friendList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            PFUser *existingUser = (PFUser *)obj;
            
            NSString *existingUsername = existingUser.username;
            NSString *addingUsername = user.username;
            
            NSComparisonResult comparisonResult = [existingUsername compare:addingUsername];
            
            if (comparisonResult == NSOrderedDescending)
            {
                index = idx;
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (pass == NSNotFound)
            index = self.friendList.count;
        
        NSMutableArray *mutableArrayForKVO = [self mutableArrayValueForKey:@"friendList"];
        [mutableArrayForKVO insertObject:user atIndex:index];
    }
}

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

//-(void) insertObject:(id)object inFriendListAtIndex:(NSUInteger)index
//{
//    [_friendList insertObject:object atIndex:index];
//}
//
//-(void) removeObjectFromFriendListAtIndex:(NSUInteger)index
//{
//    [_friendList removeObjectAtIndex:index];
//}
//
//-(void) replaceObjectInFriendListAtIndex:(NSUInteger)index withObject:(id)object
//{
//    [_friendList replaceObjectAtIndex:index withObject:object];
//}

@end
