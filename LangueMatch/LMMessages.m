#import "LMMessages.h"
#import "AppConstant.h"
#import "LMData.h"
#import "PushNotifications.h"

#import <Parse/Parse.h>

@interface LMMessages()

@property (nonatomic, strong) NSArray *chatMembers;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) PFQuery *chatQuery;

@property (nonatomic, assign) BOOL isRandomChat;

@end


//Singleton pattern
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
    }
    return self;
}


//Included in the loop when chat is open to check for new messages

-(void)checkForNewMessagesWithCompletion:(LMReceivedNewMessage)completion
{
    /* --- Query the server for new messages --- */
    
    __block NSMutableArray *fetchedMessages;
    __block NSMutableArray *newMessages;
    
    [_chatQuery includeKey:PF_MESSAGES_CLASS_NAME];
    [_chatQuery getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        
        fetchedMessages = [NSMutableArray arrayWithArray:chat[PF_MESSAGES_CLASS_NAME]];
        newMessages = [NSMutableArray array];
        
        int newMessageCount = (int)([fetchedMessages count] - [_messages count]);
        if (newMessageCount) {
            for (int i = (int)[_messages count]; i < [fetchedMessages count]; i++) {
                [newMessages addObject:fetchedMessages[i]];
            }
            
            NSRange rangeOfIndexes = NSMakeRange([_messages count], newMessageCount);
            NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
            [_messages insertObjects:newMessages atIndexes:indexSetOfNewObjects];
            
            completion(newMessageCount);
            
        } else {
            
            
        }
    }];
}


/* --- Set Messages Array from pinned datastore --- */

-(void) setChat:(PFObject *)chat
{
    _chat = chat;
    
    _isRandomChat = (BOOL)chat[PF_CHAT_RANDOM];
    
    NSMutableArray *messages = [NSMutableArray arrayWithArray:chat[PF_MESSAGES_CLASS_NAME]];
    _messages = messages;
    
    NSString *groupId = chat[PF_CHAT_GROUPID];
    _groupId = groupId;
    
    _chatQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [_chatQuery whereKey:PF_CHAT_GROUPID equalTo:_groupId];
    
    _chatMembers = chat[PF_CHAT_MEMBERS];
    
}


/* --- Pin message to datastore and send to server, when complete send push notification to user
        Messages array for both chats are saved --- */

-(void)sendMessage:(PFObject *)message withCompletion:(LMFinishedSendingMessage)completion
{
    if (!_isRandomChat) {
        [message pinInBackground];
    }
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            completion(error);
            if (!_isRandomChat) {
                [self updateChatInLocalDataStoreWithMessage:message];
            } else {
                [self updateChatOnServerWithMessage:message];
            }

            [self sendPushNotificationForMessage:message];
        }
    }];
}

-(void) updateChatInLocalDataStoreWithMessage:(PFObject *)message
{
    [_chatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        for (PFObject *chat in chats) {
            [chat addUniqueObject:message forKey:PF_MESSAGES_CLASS_NAME];
            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[LMData sharedInstance] updateChatList];
                [self updateChatOnServerWithMessage:message];
            }];
        }
    }];
}

-(void) updateChatOnServerWithMessage:(PFObject *)message
{
    [_chatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        for (PFObject *chat in chats) {
            [chat addUniqueObject:message forKey:PF_MESSAGES_CLASS_NAME];
            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            }];
        }
    }];
}

-(void)sendPushNotificationForMessage:(PFObject *)message
{
    PFQuery *queryInstallation = [PFInstallation query];
    
    NSDictionary *data = @{PF_CHAT_GROUPID : _groupId};
    
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:_chat[PF_CHAT_RECEIVER]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
//    [push setMessage:message[@"text"]];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}


@end