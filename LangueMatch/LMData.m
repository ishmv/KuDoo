#import "LMData.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMContacts.h"

@interface LMData()

@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation LMData

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
        [self getChatsForCurrentUser];
        [self getFriendsOfCurrentUser];
        
        [self searchContactsForLangueMatchUsers];
    }
    return self;
}

/* --- Queries local data store for user chats, if none found queries server --- */

#pragma mark - Query Data Store
-(void) getChatsForCurrentUser
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_SENDER equalTo:user];
    [query includeKey:PF_MESSAGES_CLASS_NAME];
    [query setLimit:50];
    [query fromLocalDatastore];
    [query orderByDescending:PF_CHAT_UPDATEDAT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        if (!error && [chats count] != 0) {
            self.chats = [NSMutableArray arrayWithArray:chats];
        } else {
            NSLog(@"No chats found on local data store.. checking servers");
            [self checkServerForNewChats];
        }
    }];
}

/* --- Queries local data store for user friends, if none found queries server --- */

-(void) getFriendsOfCurrentUser
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID equalTo:currentUser.objectId];
    [query includeKey:PF_USER_FRIENDS];
    [query fromLocalDatastore];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
        
        if (!error && [friends count] != 0) {
            self.friends = friends;
        } else {
            NSLog(@"No Friends found on local data store.. checking servers");
            [self checkServerForNewFriends];
        }
    }];
}


#pragma mark - Query Server

-(void)checkServerForNewChats
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_SENDER equalTo:user];
    [query includeKey:PF_MESSAGES_CLASS_NAME];
    [query setLimit:50];
    [query orderByDescending:PF_CHAT_UPDATEDAT];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number >= [self.chats count]) {
            [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
                [PFObject pinAllInBackground:chats];
                self.chats = [NSMutableArray arrayWithArray:chats];
            }];
        }
    }];
}


-(void)checkServerForNewFriends
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID equalTo:currentUser.objectId];
    [query includeKey:PF_USER_FRIENDS];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
        [PFObject pinAllInBackground:friends];
        self.friends = [NSMutableArray arrayWithArray:friends];
        
    }];
}


#pragma mark - Get User Friends from contacts list already on Langue Match

-(void)searchContactsForLangueMatchUsers
{
    NSArray *contacts = [LMContacts getContactEmails];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_EMAIL containedIn:contacts];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error && friends != 0) {
            
            [PFObject pinAllInBackground:friends];
            PFUser *currentUser = [PFUser currentUser];
            [currentUser addUniqueObjectsFromArray:friends forKey:PF_USER_FRIENDS];
            [currentUser saveEventually];
            [self checkServerForNewChats];
            
        } else {
            NSLog(@"Error retreiving users");
        }
    }];
    
}

@end
