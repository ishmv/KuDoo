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
    PFQuery *userQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [userQuery whereKey:PF_CHAT_USER equalTo:user];
    
    PFQuery *memberQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [memberQuery whereKey:PF_CHAT_MEMBER equalTo:user];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[userQuery, memberQuery]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        self.chats = chats;
    }];
}

-(void) startChatWithLMUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion
{
    //ToDo add if muliple person chat - do we want this?
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
            PFObject *newChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
            
            newChat[PF_CHAT_GROUPID] = groupId;
            newChat[PF_CHAT_USER] = user1;
            newChat[PF_CHAT_MEMBER] = user2;
            
            [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    completion(groupId, error);
                }
            }];
        }
    }];
    
    //Todo Search for existing chat:
    
}

-(void) saveChatToParse
{
    
}

-(void)saveChat:(NSString *)chat
{
    PFUser *user = [PFUser currentUser];
    [user addUniqueObject:chat forKey:@"chats"];
    [user saveInBackground];
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
