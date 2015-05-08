#import "LMChatsModel.h"
#import "AppConstant.h"
#import "LMParseConnection.h"

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
        [self checkLocalDataStoreForChats];
    }
    return self;
}

-(void)checkLocalDataStoreForChats
{
    if (!_chatList)
    {
        [LMParseConnection getChatsFromLocalDataStore:YES withCompletion:^(NSArray *chats, NSError *error) {
            [self willChangeValueForKey:@"chatList"];
            self.chatList = chats;
            [self didChangeValueForKey:@"chatList"];
            
            [self checkServerForChats];
        }];
    }
}

-(void)checkServerForChats
{
    [LMParseConnection getChatsFromLocalDataStore:NO withCompletion:^(NSArray *chats, NSError *error) {
        if (!error) {
            for (PFObject *chat in chats)
            {
                if (![self.chatList containsObject:chat])
                {
                    [chat pinInBackground];
                    [self addChat:chat];
                }
            }
        }
        else if (error)
        {
            NSLog(@"Could not connect to Parse server to retreive friends");
        }
    }];
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
    if (![self.chatList containsObject:chat])
    {
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

//-(void) insertObject:(id)object inChatListAtIndex:(NSUInteger)index
//{
//    [_chatList insertObject:object atIndex:index];
//}
//
//-(void) removeObjectFromChatListAtIndex:(NSUInteger)index
//{
//    [_chatList removeObjectAtIndex:index];
//}
//
//-(void) replaceObjectInChatListAtIndex:(NSUInteger)index withObject:(id)object
//{
//    [_chatList replaceObjectAtIndex:index withObject:object];
//}

@end
