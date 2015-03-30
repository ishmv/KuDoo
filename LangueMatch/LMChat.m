#import "LMChat.h"
#import "AppConstant.h"
#import "LMData.h"

#import <Parse/Parse.h>

@interface LMChat()

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
       
    }
    return self;
}

/* Initiates an isolated chat 
 
    Chat will be deleted from server once complete;
 
 */

-(void) startChatWithRandomUser:(PFUser *)user completion:(LMInitiateChatCompletionBlock)completion
{
    PFUser *user1 = [PFUser currentUser];
    PFUser *user2 = user;
    
    NSString *id1 = user1.objectId;
    NSString *id2 = user2.objectId;
    
    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
    
    PFObject *senderChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    PFObject *receiverChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    
    senderChat[PF_CHAT_GROUPID] = groupId;
    senderChat[PF_CHAT_SENDER] = user1;
    senderChat[PF_CHAT_RECEIVER] = user2;
    senderChat[PF_CHAT_TITLE] = user2.username;
    senderChat[PF_CHAT_MEMBERS] = [[NSArray alloc] initWithObjects: user1, user2, nil];
    senderChat[PF_MESSAGES_COUNTER] = @0;
    senderChat[PF_CHAT_RANDOM] = @YES;
    
    receiverChat[PF_CHAT_GROUPID] = groupId;
    receiverChat[PF_CHAT_SENDER] = user2;
    receiverChat[PF_CHAT_RECEIVER] = user1;
    receiverChat[PF_CHAT_TITLE] = user1.username;
    receiverChat[PF_CHAT_MEMBERS] = [[NSArray alloc] initWithObjects: user1, user2, nil];
    receiverChat[PF_MESSAGES_COUNTER] = @0;
    receiverChat[PF_CHAT_RANDOM] = @YES;
    
    [receiverChat saveEventually:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [senderChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            completion(senderChat, error);
        }
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
    [query whereKey:PF_CHAT_GROUPID equalTo: groupId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        if (chat) {
            completion(chat, error);
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
        
            NSError *err;
            [senderChat pin:&err];
            
            if (!err) {
                [[LMData sharedInstance] checkLocalDataStoreForChats];
            }
            
            [receiverChat saveEventually:^(BOOL succeeded, NSError *error) {
                NSLog(@"%@", error);
            }];
            
            [senderChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    completion(senderChat, error);
                }
            }];
        }
    }];
}

#pragma mark - Helper Methods



@end
