#import "LMChatViewModel.h"
#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"
#import "JSQAudioMediaItem.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

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
            
            if ([type isEqualToString:@"video"])
            {
                JSQVideoMediaItem *videoMediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:message[@"video"]] isReadyToPlay:YES];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:videoMediaItem];
            }
            
            if ([type isEqualToString:@"audio"])
            {
                JSQAudioMediaItem *audioMediaItem = [[JSQAudioMediaItem alloc] initWithFileURL:[NSURL URLWithString:message[@"audio"]] isReadyToPlay:YES];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:audioMediaItem];
            }
        }
    }
    
    return jsqMessage;
}

-(void) sendTextMessage:(NSString *)text
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    message[@"type"] = @"text";
    message[@"text"] = text;
    
    [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error != nil) {
            NSLog(@"Error Sending Message - Check network");
        }
    }];
}

-(void) sendPictureMessage:(UIImage *)picture
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    PFFile *pictureFile = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.9)];
    
    [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"picture"] = pictureFile.url;
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

-(void) sendVideoMessage:(NSURL *)url
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:url];
    PFFile *videoFile = [PFFile fileWithName:@"video.mp4" data:videoData];
    
    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"video"] = videoFile.url;
            message[@"text"] = @"Video Message";
            message[@"type"] = @"video";
            
            [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    NSLog(@"Error Sending Message - Check network");
                }
            }];
        }
    }];
}

-(void) sendAudioMessage:(NSURL *)url
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    NSData *audioData = [[NSData alloc] initWithContentsOfURL:url];
    PFFile *audioFile = [PFFile fileWithName:@"audio.m4a" data:audioData];
    
    [audioFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"audio"] = audioFile.url;
            message[@"text"] = @"Audio Message";
            message[@"type"] = @"audio";
            
            [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    NSLog(@"Error Sending Message - Check network");
                }
            }];
        }
    }];
}

-(NSMutableDictionary *) p_getSkeletonMessage
{
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"senderId"] = self.chatVC.senderId;
    message[@"senderDisplayName"] = self.chatVC.senderDisplayName;
    message[@"date"] = dateString;
    
    return message;
}

-(UIImage *) getVideoThumbnailFromVideo: (NSURL *)url
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration]; time.value = 0;

    NSError *error = nil;
    CMTime actualTime;

    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

    return thumbnail;
}


@end
