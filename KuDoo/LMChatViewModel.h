//
//  LMChatViewModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/12/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMIndexFinder)(NSInteger index);

@class LMChatViewController, JSQMessagesBubbleImage, JSQMessagesAvatarImage, Firebase, FDataSnapshot, JSQMessage, IDMPhotoBrowser;

@interface LMChatViewModel : NSObject <NSCoding>

-(instancetype) initWithViewController:(LMChatViewController *)controller;

-(NSString *) updateTypingLabelWithSnapshot:(FDataSnapshot *)snapshot;
-(NSString *) updateMemberLabelWithSnapshot:(FDataSnapshot *)snapshot;
-(void) setupFirebasesWithAddress:(NSString *)path andGroupId:(NSString *)groupId;

-(NSArray *)photos;
-(void)photoIndexForDate:(NSDate *)date withCompletion:(LMIndexFinder)completion;

-(NSAttributedString *)attributedStringForCellTopLabelFromMessage:(JSQMessage *)message withPreviousMessage:(JSQMessage *)previousMessage forIndexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) LMChatViewController *chatVC;

@property (strong, nonatomic, readonly) Firebase *messageFirebase;
@property (strong, nonatomic, readonly) Firebase *typingFirebase;
@property (strong, nonatomic, readonly) Firebase *memberFirebase;

@property (strong, nonatomic, readonly) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic, readonly) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic, readonly) JSQMessagesAvatarImage *placeholderAvatar;

@property (nonatomic, assign) BOOL initialized;

-(JSQMessage *) createMessageWithInfo:(NSDictionary *)message;

-(void) sendTextMessage:(NSString *)text;
-(void) sendPictureMessage:(UIImage *)picture;
-(void) sendVideoMessage:(NSURL *)url;
-(void) sendAudioMessage:(NSURL *)url;

-(UIImage *)getVideoThumbnailFromVideo: (NSURL *)url;

@end
