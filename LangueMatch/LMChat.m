#import "LMChat.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMChat() {
    NSMutableArray *_chats;
}

@property (nonatomic, strong) NSArray *chats;

@end

@implementation LMChat

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
    }
    return self;
}

-(void)getChatsForCurrentUser
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_SENDER equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        NSMutableArray *newChats = [chats mutableCopy];
        
        [self willChangeValueForKey:@"chats"];
        self.chats = newChats;
        [self didChangeValueForKey:@"chats"];
    }];
}

-(void) startChatWithUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion
{
    //ToDo add if muliple person chat - do we want this?
    // Maybe a chat room for Spanish, English, Japanese, etc...
    //Save user images to chat?
    
    PFUser *user1 = [PFUser currentUser];
    PFUser *user2 = users[0];
    
    NSString *id1 = user1.objectId;
    NSString *id2 = user2.objectId;

    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
    
    NSMutableArray *chatMembers = [users mutableCopy];
    [chatMembers insertObject:user1 atIndex:0];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:@"groupId" equalTo: groupId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            completion(groupId, error);
        } else {
            PFObject *senderChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
            PFObject *receiverChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
            
            senderChat[PF_CHAT_GROUPID] = groupId;
            senderChat[PF_CHAT_SENDER] = user1;
            senderChat[PF_CHAT_RECEIVER] = user2;
            senderChat[PF_CHAT_TITLE] = user2.username;
            senderChat[PF_CHAT_MEMBERS] = [[NSArray alloc] initWithObjects: user1, user2, nil];
            senderChat[PF_MESSAGES_COUNTER] = @0;
            
            receiverChat[PF_CHAT_GROUPID] = groupId;
            receiverChat[PF_CHAT_SENDER] = user2;
            receiverChat[PF_CHAT_RECEIVER] = user1;
            receiverChat[PF_CHAT_TITLE] = user1.username;
            receiverChat[PF_CHAT_MEMBERS] = [[NSArray alloc] initWithObjects: user1, user2, nil];
            receiverChat[PF_MESSAGES_COUNTER] = @0;
            
            [self saveReceiverChat:receiverChat];
            
            [senderChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    NSMutableArray *chat = [self mutableArrayValueForKey:@"chats"];
                    [chat insertObject:senderChat atIndex:0];
                    completion(groupId, error);
                }
            }];
        }
    }];
    
    //Todo Search for existing chat:
}

-(void) saveReceiverChat:(PFObject *)chat
{
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved Receiver Chat");
        } else {
            NSLog(@"error saving receiver chat %@", error);
        }
    }];
}

#pragma mark - KVO Methods

-(NSUInteger) countOfChats
{
    return self.chats.count;
}

-(id) objectInChatsAtIndex:(NSUInteger)index
{
    return [self.chats objectAtIndex:index];
}

-(NSArray *) chatsAtIndexes:(NSIndexSet *)indexes
{
    return [self.chats objectsAtIndexes:indexes];
}

-(void) insertObject:(PFObject *)object inChatsAtIndex:(NSUInteger)index
{
    [_chats insertObject:object atIndex:index];
}

-(void) removeChatsFromUsersAtIndex:(NSUInteger)index
{
    [_chats removeObjectAtIndex:index];
}

-(void) replaceObjectInChatsAtIndex:(NSUInteger)index withChat:(id)object
{
    [_chats replaceObjectAtIndex:index withObject:object];
}


@end
