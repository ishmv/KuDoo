#import "LMChatViewModel.h"
#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"
#import "JSQAudioMediaItem.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface LMChatViewModel()

@end

@implementation LMChatViewModel

#pragma mark - Application Life Cycle

-(instancetype) initWithViewController:(LMChatViewController *)controller
{
    if (self = [super init]) {
        _chatVC = (LMChatViewController *)controller;

        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        _outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lm_beigeColor]];
        _incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor lm_tealBlueColor]];
    }
    return self;
}

#pragma mark - Public Methods

-(NSString *) updateTypingLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    NSArray *children = nil;
    
    NSString *typingText;
    
    if (childrenCount) {
        children = [self p_getChildInformationForSnapshot:snapshot];
    }
    
    if (children.count > 1) {
        typingText = NSLocalizedString(@"Two or more people are typing", @"two or more people are typing");
    } else if (children.count == 1){
        typingText = [NSString stringWithFormat: @"%@ %@", children[0], NSLocalizedString(@"is typing...", @"is typing...")];
    } else {
        typingText = @"";
    }
    
    return typingText;
}

-(NSString *) updateMemberLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSUInteger childrenCount = snapshot.childrenCount;
    NSArray *children;
    
    if (childrenCount) {
        children = [self p_getChildInformationForSnapshot:snapshot];
    }
    
    NSString *onlineText;
    
    if (children != nil) {
        if (children.count > 1) {
            onlineText = NSLocalizedString(@"Two or more people online", @"two or more people online");
        } else if (children.count == 1){
            onlineText = [NSString stringWithFormat:@"%@ is online", children[0]];
        } else {
            onlineText = @"";
        }
    }
    
    return onlineText;
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
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        mediaItem.image = (UIImage *)responseObject;
                        [self.chatVC.collectionView reloadData];
                    });
                    
                    [self.chatVC storeImage:(UIImage *)responseObject forDate:date];
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed retreiving message");
                }];
                
                [[NSOperationQueue mainQueue] addOperation:operation];
            }
            
            if ([type isEqualToString:@"video"])
            {
                JSQVideoMediaItem *videoMediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:message[@"video"]] isReadyToPlay:YES];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:videoMediaItem];
                videoMediaItem.videoThumbnail = [self p_getVideoThumbnailFromVideo:[NSURL URLWithString:message[@"video"]]];
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

-(void) saveTextMessage:(NSString *)text toFirebase:(Firebase *)firebase
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    message[@"type"] = @"text";
    message[@"text"] = text;
    
    [[firebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error != nil) {
            NSLog(@"Error Sending Message - Check network");
        }
    }];
}

-(void) savePictureMessage:(UIImage *)picture toFirebase:(Firebase *)firebase
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    PFFile *pictureFile = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.9)];
    
    [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"picture"] = pictureFile.url;
            message[@"text"] = @"Picture Message";
            message[@"type"] = @"picture";
            
            [[firebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    NSLog(@"Error Sending Message - Check network");
                }
            }];
        }
    }];
}

-(void) saveVideoMessage:(NSURL *)url toFirebase:(Firebase *)firebase
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:url];
    PFFile *videoFile = [PFFile fileWithName:@"video.mp4" data:videoData];
    
    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"video"] = videoFile.url;
            message[@"text"] = @"Video Message";
            message[@"type"] = @"video";
            
            [[firebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    NSLog(@"Error Sending Message - Check network");
                }
            }];
        }
    }];
}

-(void) saveAudioMessage:(NSURL *)url toFirebase:(Firebase *)firebase
{
    NSMutableDictionary *message = [self p_getSkeletonMessage];
    
    NSData *audioData = [[NSData alloc] initWithContentsOfURL:url];
    PFFile *audioFile = [PFFile fileWithName:@"audio.m4a" data:audioData];
    
    [audioFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            message[@"audio"] = audioFile.url;
            message[@"text"] = @"Audio Message";
            message[@"type"] = @"audio";
            
            [[firebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    NSLog(@"Error Sending Message - Check network");
                }
            }];
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
    
    NSDictionary *dateTextAttributes = @{ NSFontAttributeName : [UIFont lm_robotoLightMessagePreview],
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

#pragma mark - Private Methods

-(NSArray *) p_getChildInformationForSnapshot:(FDataSnapshot *)snapshot
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

-(NSMutableDictionary *) p_getSkeletonMessage
{
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"senderId"] = self.chatVC.senderId;
    message[@"senderDisplayName"] = self.chatVC.senderDisplayName;
    message[@"date"] = dateString;
    
    return message;
}

-(UIImage *) p_getVideoThumbnailFromVideo: (NSURL *)url
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
