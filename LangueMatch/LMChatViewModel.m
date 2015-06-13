#import "LMChatViewModel.h"
#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface LMChatViewModel()

@property (strong, nonatomic, readwrite) LMChatViewController *chatVC;

@property (strong, nonatomic, readwrite) Firebase *messageFirebase;
@property (strong, nonatomic, readwrite) Firebase *typingFirebase;
@property (strong, nonatomic, readwrite) Firebase *memberFirebase;

@property (strong, nonatomic, readwrite) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic, readwrite) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic, readwrite) JSQMessagesAvatarImage *placeholderAvatar;

@end

@implementation LMChatViewModel

-(instancetype) initWithViewController:(LMChatViewController *)controller
{
    if (self = [super init]) {
        _chatVC = (LMChatViewController *)controller;
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
        self.incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    }
    return self;
}

-(NSString *) updateTypingLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    NSMutableArray *children;
    
    NSString *typingText;
    
    if (childrenCount) {
        children = [[NSMutableArray alloc] init];
        for (FDataSnapshot *child in snapshot.children) {
            if (![[child key] isEqualToString:_chatVC.senderDisplayName]) {
                [children addObject:[child key]];
            }
        }
    }
    
    if (children.count > 1) {
        typingText = @"2 or more people are typing...";
    } else if (children.count == 1){
        typingText = [NSString stringWithFormat:@"%@ is typing...", children[0]];
    } else {
        typingText = [NSString stringWithFormat:@"%lu people online", _chatVC.peopleOnline];
    }
    
    return typingText;
}

-(NSString *) updateTitleLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    _chatVC.peopleOnline = childrenCount;
    
    NSString *titleText;
    
    if (childrenCount == 1) {
        titleText = [NSString stringWithFormat:@"%@", _chatVC.chatTitle];
    } else if (childrenCount == 2) {
        for (FDataSnapshot *child in snapshot.children) {
            if (![child.key isEqualToString:[PFUser currentUser].username]) {
                titleText = [NSString stringWithFormat:@"%@ is online", child.key];
            }
        }
    } else if (childrenCount > 2) {
        titleText = [NSString stringWithFormat:@"%lu people online", (unsigned long)childrenCount];
    }
    
    return titleText;

}

-(void) setupFirebasesWithAddress:(NSString *)path andGroupId:(NSString *)groupId
{
    self.messageFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@/messages", path, groupId]];
    self.typingFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@/typing", path, groupId]];
    self.memberFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@/members", path, groupId]];
    
    [self.typingFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.chatVC refreshTypingLabelWithSnapshot:snapshot];
    }];
    
    [self.memberFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.chatVC refreshTitleLabelWithSnapshot:snapshot];
    }];
    
    [self.messageFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.chatVC createMessageWithInfo:snapshot.value];
    }];
    
    if (!_initialized) {
        [self.messageFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self.chatVC finishReceivingMessage];
            [self.chatVC scrollToBottomAnimated:NO];
            self.chatVC.automaticallyScrollsToMostRecentMessage = YES;
            _initialized = YES;
        }];
    }
}

-(JSQMessage *) createMessageWithInfo:(NSDictionary *)message
{
    NSDate *date = [NSDate lm_stringToDate:message[@"date"]];
    
    JSQMessage *jsqMessage;
    JSQMessage *lastMessage = [_chatVC.allMessages lastObject];
    
    if (date > lastMessage.date || lastMessage == nil) {
        
        NSString *type = message[@"type"];
        NSString *senderId = message[@"senderId"];
        NSString *senderDisplayName = message[@"senderDisplayName"];
        
        if ([type isEqualToString:@"text"]) {
            
            jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:message[@"text"]];
            
        } else {
            
            if ([type isEqualToString:@"picture"]) {
                
                JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:mediaItem];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message[@"picture"]]];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.responseSerializer = [AFImageResponseSerializer serializer];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    mediaItem.image = (UIImage *)responseObject;
                    [self.chatVC.collectionView reloadData];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed retreiving message");
                }];
                
                [[NSOperationQueue mainQueue] addOperation:operation];
            }
        }
    }
    
    return jsqMessage;
}

-(void) sendMessage:(NSString *)text withMedia:(id)media
{
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"senderId"] = self.chatVC.senderId;
    message[@"senderDisplayName"] = self.chatVC.senderDisplayName;
    message[@"date"] = dateString;
    
    if (text) {
        message[@"type"] = @"text";
        message[@"text"] = text;
        
        [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error != nil) {
                NSLog(@"Error Sending Message - Check network");
            }
        }];
        
    } else if (media) {
        PFFile *file;
        
        if ([media isKindOfClass:[UIImage class]]) {
            file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(media, 0.9)];
            
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error == nil) {
                    message[@"picture"] = file.url;
                    message[@"text"] = @"Picture Message";
                    message[@"type"] = @"picture";
                    
                    [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                        if (error != nil) {
                            NSLog(@"Error Sending Message - Check network");
                        }
                    }];
                }
            }];
        }
    }
}

@end
