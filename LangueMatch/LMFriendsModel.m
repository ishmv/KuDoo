#import "LMFriendsModel.h"
#import "AppConstant.h"
#import "LMParseConnection+Friends.h"

#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface LMFriendsModel() {
    NSMutableArray *_friendList;
}

@property (strong, nonatomic) NSArray *friendList;

@end

@implementation LMFriendsModel

static id sharedInstance;

// Use with Caution!!

+(instancetype) sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

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
            [self p_orderFriends];
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
                    [user pinInBackgroundWithName:PF_USER_FRIENDSHIPS];
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

-(void)dealloc
{
    sharedInstance = nil;
}

-(void) p_orderFriends
{
   NSArray *sortedFriendsList = [self.friendList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PFUser *user1 = (PFUser *)obj1;
        PFUser *user2 = (PFUser *)obj2;
        
        NSString *username1 = [user1.username lowercaseString];
        NSString *username2 = [user2.username lowercaseString];
        
        NSComparisonResult comparisonResult = [username1 compare:username2];
        
        if (comparisonResult == NSOrderedAscending) return NSOrderedAscending;
        if (comparisonResult == NSOrderedDescending) return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    [self willChangeValueForKey:@"friendList"];
    self.friendList = sortedFriendsList;
    [self didChangeValueForKey:@"friendList"];
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

@end
