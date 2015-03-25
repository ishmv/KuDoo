#import "LMMessages.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

#import "LMData.h"

@interface LMMessages()

@property (nonatomic, strong) NSArray *chatMembers;
@property (nonatomic, assign) int messageCounter;

@end

@implementation LMMessages

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.messages = [NSMutableArray array];
    }
    return self;
}

-(void)checkForNewMessagesWithCompletion:(LMReceivedNewMessage)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:self.groupID];
    [query includeKey:PF_MESSAGES_CLASS_NAME];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        
        NSMutableArray *fetchedMessages = [NSMutableArray arrayWithArray:chat[PF_MESSAGES_CLASS_NAME]];
        NSMutableArray *newMessages = [NSMutableArray array];
        
        if ([fetchedMessages count] == _messages.count) {
            
            NSLog(@"No Messages");
            
        } else {
            
            int newMessageCount = (int)([fetchedMessages count] - [_messages count]);
            if (newMessageCount) {
                for (int i = (int)[_messages count]; i < [fetchedMessages count]; i++) {
                    [newMessages addObject:fetchedMessages[i]];
                }
                
                NSRange rangeOfIndexes = NSMakeRange([_messages count], newMessageCount);
                NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
                [self.messages insertObjects:newMessages atIndexes:indexSetOfNewObjects];
                
                completion(newMessageCount);
                
            } else {
                
            }
        }
    }];
}


-(void) setMessages:(NSMutableArray *)messages
{
    _messages = messages;
}

-(void)getMembersOfChat
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:self.groupID];
    [query includeKey:PF_CHAT_MEMBERS];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.chatMembers = object[PF_CHAT_MEMBERS];
    }];
}

-(void)sendMessage:(PFObject *)message withCompletion:(LMFinishedSendingMessage)completion
{
    [message pinInBackground];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            completion(error);
            [self saveMessageToChat:message];
            [self sendPushNotificationForMessage:message];
        }
    }];
}


-(void) saveMessageToChat:(PFObject *)message
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:message[PF_CHAT_GROUPID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        for (PFObject *chat in chats) {
            [chat addUniqueObject:message forKey:PF_MESSAGES_CLASS_NAME];
            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
}

-(void)sendPushNotificationForMessage:(PFObject *)message
{
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER notEqualTo:[PFUser currentUser]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setMessage:message[@"text"]];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}


@end