#import "LMUsers.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMUsers() {
    NSMutableArray *_users;
}

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *randomUsers;

@end

@implementation LMUsers

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init
{
    if (self = [super init]) {
        [self getLMUsers];
    }
    return self;
}

-(void)getLMUsers
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query fromLocalDatastore];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        self.users = users;
        [PFObject pinAllInBackground:users];
    }];
}

-(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *desiredLanguage = currentUser[PF_USER_DESIRED_LANGUAGE];
    
    [query whereKey:PF_USER_FLUENT_LANGUAGE equalTo:desiredLanguage];
    
    //ToDo omit friends from query
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFUser *user = (PFUser *)object;
            completion(user, error);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No One Found", @"No One Found") message:NSLocalizedString(@"Please Try Again Later", @"Please Try Again Later") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

#pragma mark - KVO Methods

-(NSUInteger) countOfUsers
{
    return self.users.count;
}

-(id) objectInUsersAtIndex:(NSUInteger)index
{
    return [self.users objectAtIndex:index];
}

-(NSArray *) usersAtIndexes:(NSIndexSet *)indexes
{
    return [self.users objectsAtIndexes:indexes];
}

-(void) insertObject:(PFUser *)object inUsersAtIndex:(NSUInteger)index
{
    [_users insertObject:object atIndex:index];
}

-(void) removeObjectFromUsersAtIndex:(NSUInteger)index
{
    [_users removeObjectAtIndex:index];
}

-(void) replaceObjectInUsersAtIndex:(NSUInteger)index withObject:(id)object
{
    [_users replaceObjectAtIndex:index withObject:object];
}

@end
