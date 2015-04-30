#import "LMChatsModel.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMChatsModel() {
    NSMutableArray *_chatList;
}

@property (strong, nonatomic) NSArray *chatList;

@end

@implementation LMChatsModel

-(instancetype) init
{
    if (self = [super init]) {
        [self checkServerForChats];
    }
    return self;
}

/* -- Query local data store since friends were pinned at signup -- */

-(void)checkServerForChats
{
    if (!_chatList) {
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *queryChat = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [queryChat whereKey:PF_CHAT_SENDER equalTo:currentUser];
        [queryChat includeKey:PF_CHAT_MESSAGES];
        [queryChat includeKey:PF_CHAT_MEMBERS];
        [queryChat setLimit:50];
        [queryChat orderByDescending:PF_CHAT_UPDATEDAT];
        
        [queryChat findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
            
            NSMutableArray *nonRandomChats = [NSMutableArray new];
            
            // Check to make sure chat is not random - if so add it
            
            for (PFObject *chat in chats) {
                if (!chat[PF_CHAT_RANDOM]) {
                    [nonRandomChats addObject:chat];
                } else {
                    [chat deleteEventually];
                }
            }
            
            [PFObject pinAllInBackground:nonRandomChats];
            
            // LMListViewController will always have a strong pointer to LMFriendsModel, so no need for weak/strong dance
            [self willChangeValueForKey:@"friendList"];
            self.chatList = nonRandomChats;
            [self didChangeValueForKey:@"friendList"];
        }];
    }
    else if (_chatList)
    {
        for (PFObject *chat in _chatList) {
            [chat fetchIfNeededInBackground];
        }
    }
}


-(void)deleteChat:(PFObject *)chat
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatList"];
    [mutableArrayWithKVO removeObject:chat];
    [chat unpinInBackground];
    [chat deleteInBackground];
}

-(void)addChat:(PFObject *)chat
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatList"];
    [mutableArrayWithKVO insertObject:chat atIndex:0];
}

-(void) update
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatList"];
    
    [mutableArrayWithKVO sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        PFObject *chat1 = (PFObject *)obj1;
        PFObject *chat2 = (PFObject *)obj2;
        
        NSDate *date1 = chat1[PF_CHAT_UPDATEDAT];
        NSDate *date2 = chat2[PF_CHAT_UPDATEDAT];
        
        if (date1 > date2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (date1 < date2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
}

#pragma mark - Key/Value Observing

-(NSUInteger)countOfChatList
{
    return self.chatList.count;
}

-(id) objectInChatListAtIndex:(NSUInteger)index
{
    return [self.chatList objectAtIndex:index];
}

-(NSArray *) chatListAtIndexes:(NSIndexSet *)indexes
{
    return [self.chatList objectsAtIndexes:indexes];
}

-(void) insertObject:(id)object inChatListAtIndex:(NSUInteger)index
{
    [_chatList insertObject:object atIndex:index];
}

-(void) removeObjectFromChatListAtIndex:(NSUInteger)index
{
    [_chatList removeObjectAtIndex:index];
}

-(void) replaceObjectInChatListAtIndex:(NSUInteger)index withObject:(id)object
{
    [_chatList replaceObjectAtIndex:index withObject:object];
}

@end
