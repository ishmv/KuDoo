#import "LMData.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMContacts.h"

@interface LMData()

@property (strong, nonatomic) NSMutableArray *chats;

@property (strong, nonatomic) PFQuery *chatQuery;


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
        [queryChat includeKey:PF_MESSAGE_CLASS_NAME];
        [queryChat includeKey:PF_CHAT_MEMBERS];
        [queryChat setLimit:50];
        [queryChat orderByDescending:PF_CHAT_UPDATEDAT];
        _chatQuery = queryChat;
        
        // Called once for login screen is presented - use local datastore after
        [self checkServerForNewChats];
        
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
