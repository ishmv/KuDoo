#import "LMMessageModel.h"
#import "AppConstant.h"

#import <Parse/Parse.h>
#import <JSQMessages.h>

@interface LMMessageModel() {
    NSMutableArray *_chatMessages;
}

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) NSArray *chatMessages;

@end

@implementation LMMessageModel

-(instancetype)initWithChat:(PFObject *)chat
{
    if (self = [super init]) {
        _chat = chat;
        [self addMessagesToArray];
    }
    return self;
}


-(void)addMessagesToArray
{
    if (!_chatMessages) {
        [self willChangeValueForKey:@"chatMessages"];
        self.chatMessages = [NSMutableArray new];
        [self didChangeValueForKey:@"chatMessages"];
    }
    
    NSArray *LMMessages = _chat[PF_CHAT_MESSAGES];
    
    for (PFObject *message in LMMessages) {
        [self addChatMessagesObject:message];
    }
}

-(void) addChatMessagesObject:(PFObject *)message
{
    
    JSQMessage *messageToAdd;
    [message pinInBackground];
    
    if (message[PF_MESSAGE_IMAGE]) {
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:message[PF_MESSAGE_IMAGE]];
        messageToAdd = [JSQMessage messageWithSenderId:message[PF_MESSAGE_SENDER_ID] displayName:message[PF_MESSAGE_SENDER_NAME] media:photoItem];
    }
    else if (message[PF_MESSAGE_VIDEO]) {
        //ToDo
    } else if (message[PF_MESSAGE_VOICETEXT]) {
        
    } else {
        messageToAdd = [JSQMessage messageWithSenderId:message[PF_MESSAGE_SENDER_ID] displayName:message[PF_MESSAGE_SENDER_NAME] text:message[PF_MESSAGE_TEXT]];
    }
    
    if (![self.chatMessages containsObject:messageToAdd]) {
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"chatMessages"];
        [mutableArrayWithKVO insertObject:messageToAdd atIndex:[_chatMessages count]];
    }
}


#pragma mark - Key/Value Observing

-(NSUInteger)countOfChatMessages
{
    return self.chatMessages.count;
}

-(id) objectInChatMessagesAtIndex:(NSUInteger)index
{
    return [self.chatMessages objectAtIndex:index];
}

-(NSArray *) chatMessagesAtIndexes:(NSIndexSet *)indexes
{
    return [self.chatMessages objectsAtIndexes:indexes];
}

-(void) insertObject:(id)object inChatMessagesAtIndex:(NSUInteger)index
{
    [_chatMessages insertObject:object atIndex:index];
}

-(void) removeObjectFromChatMessagesAtIndex:(NSUInteger)index
{
    [_chatMessages removeObjectAtIndex:index];
}

-(void) replaceObjectInChatMessagesAtIndex:(NSUInteger)index withObject:(id)object
{
    [_chatMessages replaceObjectAtIndex:index withObject:object];
}

@end
