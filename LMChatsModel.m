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
        [queryChat includeKey:PF_MESSAGES_CLASS_NAME];
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
}


-(void)deleteChat:(PFObject *)chat
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatList"];
    [mutableArrayWithKVO removeObject:chat];
    [chat deleteEventually];
}

-(void)addChat:(PFObject *)chat
{
    if (![self.chatList containsObject:chat]) {
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatList"];
        [mutableArrayWithKVO insertObject:chat atIndex:0];
    }
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
