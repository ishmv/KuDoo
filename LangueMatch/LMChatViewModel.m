#import "LMChatViewModel.h"
#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"
#import "JSQAudioMediaItem.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface LMChatViewModel()

@property (strong, nonatomic, readwrite) NSMutableArray *photosArray;
@property (strong, nonatomic, readwrite) NSMutableOrderedSet *photoMapper;

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
        
        if (!_photosArray) {
            self.photosArray = [[NSMutableArray alloc] init];
        }
        
        if (!_photoMapper) {
            self.photoMapper = [[NSMutableOrderedSet alloc] init];
        }
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lm_beigeColor]];
        self.incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor lm_tealColor]];
    }
    return self;
}

-(NSString *) updateTypingLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    NSArray *children = nil;
    
    NSString *typingText;
    
    if (childrenCount) {
        children = [self p_getInformationForSnapshot:snapshot];
    }
    
    if (children.count > 1) {
        typingText = NSLocalizedString(@"Two or more people are typing", @"Typing label");
    } else if (children.count == 1){
        typingText = [NSString stringWithFormat:@"%@ is typing...", children[0]];
    } else {
        typingText = @"";
    }
    
    return typingText;
}

-(NSString *) updateMemberLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    _chatVC.peopleOnline = childrenCount;
    NSArray *children;
    
    if (childrenCount) {
        children = [self p_getInformationForSnapshot:snapshot];
    }
    
    NSString *onlineText;
    
    if (children != nil) {
        if (children.count > 1) {
            onlineText = NSLocalizedString(@"Two or more people online", @"Online label");
        } else if (children.count == 1){
            onlineText = [NSString stringWithFormat:@"%@ is online", children[0]];
        } else {
            onlineText = @"";
        }
    }
    
    return onlineText;
}

-(NSArray *) p_getInformationForSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    NSMutableArray *children;
    
    if (childrenCount) {
        children = [[NSMutableArray alloc] init];
        for (FDataSnapshot *child in snapshot.children) {
            if (![[child key] isEqualToString:_chatVC.senderId]) {
                NSDictionary *dict = child.value;
                [children addObject:[dict objectForKey:@"senderDisplayName"]];
            }
        }
    }
    
    return children;
}

-(void) setupFirebasesWithAddress:(NSString *)path andGroupId:(NSString *)groupId
{
    self.messageFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/messages", path, groupId]];
    self.typingFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/typing", path, groupId]];
    self.memberFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/members", path, groupId]];
    
    [self.typingFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.chatVC refreshTypingLabelWithSnapshot:snapshot];
    }];
    
    [self.memberFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.chatVC refreshMemberLabelWithSnapshot:snapshot];
    }];
    
    [[self.messageFirebase queryLimitedToLast:20] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.chatVC createMessageWithInfo:snapshot.value];
        [self.chatVC scrollToBottomAnimated:NO];
    }];
    
//    if (!_initialized) {
//        [[self.messageFirebase queryLimitedToLast:5] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//            [self.chatVC createMessageWithInfo:snapshot.value];
//            [self.chatVC finishReceivingMessage];
//            [self.chatVC scrollToBottomAnimated:NO];
//            self.chatVC.automaticallyScrollsToMostRecentMessage = YES;
//            _initialized = YES;
//        }];
//    }
    
    //Methods before message limiting:
//    [self.messageFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        [self.chatVC createMessageWithInfo:snapshot.value];
//    }];
    
//    if (!_initialized) {
//        [self.messageFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//            [self.chatVC finishReceivingMessage];
//            [self.chatVC scrollToBottomAnimated:NO];
//            self.chatVC.automaticallyScrollsToMostRecentMessage = YES;
//            _initialized = YES;
//        }];
//    }
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
                    
                    IDMPhoto *photo = [IDMPhoto photoWithImage:(UIImage *)responseObject];
                    [self.photosArray addObject:photo];
                    [self.photoMapper addObject:date];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed retreiving message");
                }];
                
                [[NSOperationQueue mainQueue] addOperation:operation];
            }
            
            if ([type isEqualToString:@"video"])
            {
                JSQVideoMediaItem *videoMediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:message[@"video"]] isReadyToPlay:YES];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:videoMediaItem];
                videoMediaItem.videoThumbnail = [self getVideoThumbnailFromVideo:[NSURL URLWithString:message[@"video"]]];
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

-(NSArray *)photos
{
    return [self.photosArray copy];
}

-(void)photoIndexForDate:(NSDate *)date withCompletion:(LMIndexFinder)completion
{
    [self.photoMapper enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *storeDate = (NSDate *)obj;
        
        NSComparisonResult result = [storeDate compare:date];
        
        if (result == NSOrderedSame) {
            completion(idx);
            *stop = YES;
        }
    }];
}

-(NSAttributedString *) attributedStringForCellTopLabelFromMessage:(JSQMessage *)message withPreviousMessage:(JSQMessage *)previousMessage forIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDoesRelativeDateFormatting:YES];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *dateTextAttributes = @{ NSFontAttributeName : [UIFont lm_noteWorthySmall],
                                          NSForegroundColorAttributeName : [UIColor blackColor],
                                          NSParagraphStyleAttributeName : paragraphStyle};
    
    NSString *currentMessageDate;
    
    if (indexPath.item == 0) {
        currentMessageDate = [formatter stringFromDate:message.date];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:currentMessageDate attributes:dateTextAttributes];
        return attributedString;
    }
    
    if (previousMessage != nil)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
        
        currentMessageDate = [dateFormatter stringFromDate:message.date];
        NSString *previousMessageDate = [dateFormatter stringFromDate:previousMessage.date];
        
        if (![currentMessageDate compare:previousMessageDate] == NSOrderedSame)
        {
            currentMessageDate = [formatter stringFromDate:message.date];
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:currentMessageDate attributes:dateTextAttributes];
            
            return attributedString;
        }
    }
    
    return nil;
}

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.photosArray = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(photosArray))];
        self.photoMapper = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(photoMapper))];
        
    } else {
        return nil;
    }
    
    if (!_outgoingMessageBubble) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lm_beigeColor]];
        self.incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor lm_tealColor]];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.photosArray forKey:NSStringFromSelector(@selector(photosArray))];
    [aCoder encodeObject:self.photoMapper forKey:NSStringFromSelector(@selector(photoMapper))];
}

@end
