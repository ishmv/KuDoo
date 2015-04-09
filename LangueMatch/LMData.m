#import "LMData.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMContacts.h"

@interface LMData()

@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableArray *friends;

@property (strong, nonatomic) PFQuery *chatQuery;
@property (strong, nonatomic) PFQuery *friendQuery;

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
        //Set base chat query
        PFUser *user = [PFUser currentUser];
        
        PFQuery *queryChat = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [queryChat whereKey:PF_CHAT_SENDER equalTo:user];
        [queryChat includeKey:PF_MESSAGES_CLASS_NAME];
        [queryChat includeKey:PF_CHAT_MEMBERS];
        [queryChat setLimit:50];
        [queryChat orderByDescending:PF_CHAT_UPDATEDAT];
        _chatQuery = queryChat;
        
        //set base friend query
        PFQuery *friendQueries = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [friendQueries whereKey:PF_USER_OBJECTID equalTo:user.objectId];
        [friendQueries includeKey:PF_USER_FRIENDS];
        _friendQuery = friendQueries;
        
        // Called once for login screen is presented - use local datastore after
        [self checkServerForNewChats];
        [self checkServerForNewFriends];
        
    }
    return self;
}

/* --- Queries local data store for user chats, if none found queries server --- */

#pragma mark - Query Data Store
-(void) checkLocalDataStoreForChats
{
    [_chatQuery fromLocalDatastore];
    [_chatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        
        NSMutableArray *fetchedChats = [NSMutableArray arrayWithArray:chats];
        [self updateChatsWithNewChatsFromArray:fetchedChats];
    }];
}

-(void)updateChatList
{
    [_chatQuery fromLocalDatastore];
    [_chatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        NSMutableArray *fetchedChats = [NSMutableArray arrayWithArray:chats];
        [_chats replaceObjectsInRange:NSMakeRange(0, [_chats count]) withObjectsFromArray:fetchedChats];
    }];
}

/* --- Queries local data store for user friends, if none found queries server --- */

-(void) getFriendsOfCurrentUser
{
    [_friendQuery fromLocalDatastore];
    [_friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
        
        if (!error && [friends count] != 0) {
            _friends = friends;
        } else {
            NSLog(@"No Friends found on local data store.. checking servers");
            [self checkServerForNewFriends];
        }
    }];
}


#pragma mark - Query Server

-(void)checkServerForNewChats
{
    [_chatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        
        NSMutableArray *fetchedChats;
        NSMutableArray *nonRandomChats = [NSMutableArray new];
        
        // Check to make sure chat is not random - if so add it
        
        for (PFObject *chat in chats) {
            if (!chat[PF_CHAT_RANDOM]) {
                [nonRandomChats addObject:chat];
            } else {
                [chat deleteEventually];
            }
        }
        
        fetchedChats = nonRandomChats;
        [PFObject pinAllInBackground:fetchedChats];
        _chats = fetchedChats;
    }];
}


-(void)checkServerForNewFriends
{
    [_friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        NSMutableArray *friends = [NSMutableArray arrayWithArray:user[PF_USER_FRIENDS]];
        [PFObject pinAllInBackground:friends];
        _friends = [NSMutableArray arrayWithArray:friends];
        
    }];
}


#pragma mark - Get User Friends from contacts list already on Langue Match

-(void)searchContactsForLangueMatchUsers
{
    NSArray *contacts = [LMContacts getPhoneBookEmails];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_EMAIL containedIn:contacts];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error && friends != 0) {
            
            [PFObject pinAllInBackground:friends];
            PFUser *currentUser = [PFUser currentUser];
            [currentUser addUniqueObjectsFromArray:friends forKey:PF_USER_FRIENDS];
            [currentUser saveEventually];
            [self checkServerForNewFriends];
            
        } else {
            NSLog(@"Error retreiving users");
        }
    }];
    
}

#pragma mark - Helper Method

//Get most recent chats and insert to _chats array

-(void)updateChatsWithNewChatsFromArray:(NSMutableArray *)array
{
    NSMutableArray *newChats = [NSMutableArray new];
    NSIndexSet *indexSetOfNewObjects;
    
    int newChatCount = (int)([array count] - [_chats count]);
    
    for (int i = 0; i < newChatCount; i++) {
        
        PFObject *chat = array[i];
        [newChats addObject:chat];
    }
    
    NSRange rangeOfIndexes = NSMakeRange(0, newChatCount);
    indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
    [_chats insertObjects:newChats atIndexes:indexSetOfNewObjects];
}

@end
