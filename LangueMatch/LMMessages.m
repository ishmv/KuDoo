#import "LMMessages.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMMessages()

@property (nonatomic, strong) NSArray *chatMembers;
@property (nonatomic, assign) int messageCounter;
@property (strong, nonatomic) NSString *groupID;

@end

@implementation LMMessages


-(instancetype) initWithGroupID:(NSString *)groupId
{
    if (self = [super init]) {
        if (!self.messages) {
            self.groupID = groupId;
            self.messages = [NSMutableArray new];
            [self checkForNewMessages];
            [self getMembersOfChat];
        }
    }
    return self;
}

-(void)checkForNewMessages
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:self.groupID];
    [query includeKey:PF_MESSAGES_CLASS_NAME];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        
        NSMutableArray *fetchedMessages = [NSMutableArray arrayWithArray:chat[PF_MESSAGES_CLASS_NAME]];
        NSMutableArray *newMessages = [NSMutableArray array];
        
        if ([fetchedMessages count] == 0) {
            
//            NSLog(@"No Messages");
            
        } else {
            int newMessageCount = (int)([fetchedMessages count] - [_messages count]);
            
            if (newMessageCount) {
                for (int i = (int)[_messages count]; i < [fetchedMessages count]; i++) {
                    [newMessages addObject:fetchedMessages[i]];
                }
                
                NSRange rangeOfIndexes = NSMakeRange([_messages count], newMessageCount);
                NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
                [self.messages insertObjects:newMessages atIndexes:indexSetOfNewObjects];
                
            } else {
//                NSLog(@"No New Messages");
            }
        }
    }];
}


-(void)dealloc
{
    NSLog(@"dealloc LMMessages");
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
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [self.messages insertObject:message atIndex:[_messages count]];
            completion(error);
            [self saveMessageToChat:message];
        }
        
    }];
}


-(void) saveMessageToChat:(PFObject *)message
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_GROUPID equalTo:message[PF_CHAT_GROUPID]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        if (chat) {
            [chat addUniqueObject:message forKey:PF_MESSAGES_CLASS_NAME];
            [chat incrementKey:PF_MESSAGES_COUNTER];
            
            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
//                    [self checkForNewMessages];
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
}


@end