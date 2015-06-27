//
//  LMChatViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessages.h>

@class Firebase, FDataSnapshot;

@protocol LMChatViewControllerDelegate <NSObject>

@optional

-(void) lastMessage:(NSDictionary *)lastMessage forChat:(NSString *)groupId;
-(void) incrementedNewMessageCount:(NSInteger)messageCount ForChat:(NSString *)groupId;
-(void) numberOfPeopleOnline:(NSInteger)online changedForChat:(NSString *)groupId;
-(void) peopleTypingText:(NSString *)typingText;

@end

@interface LMChatViewController : JSQMessagesViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, JSQMessagesInputToolbarDelegate>

/*
 
 Default initializer. Address will be used to create a firebase where the chat informatioon (users, messages, etc..) is stored.
 Using NSObject default initalizer will raise an exception;
 
*/
-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId;

-(void) refreshTypingLabelWithSnapshot:(FDataSnapshot *)snapshot;
-(void) refreshMemberLabelWithSnapshot:(FDataSnapshot *)snapshot;
-(void) createMessageWithInfo:(NSDictionary *)message;

-(void) sendAudioMessageWithUrl:(NSURL *)url;
-(void) sendPictureMessageWithImage:(UIImage *)image;
-(void) sendVideoMessageWithURL:(NSURL *)url;

/*

 The firebase associated with the chat

*/
@property (copy, readonly, nonatomic) NSString *firebaseAddress;

/*

 The groupId associated with the chat
 
*/
@property (copy, readonly, nonatomic) NSString *groupId;

/*
 
 
*/
@property (nonatomic, strong) UIImage *backgroundImage;

/*

 
*/
@property (strong, nonatomic) UIColor *backgroundColor;

/*
 
 
 
 */
@property (weak, nonatomic) id <LMChatViewControllerDelegate> delegate;

/*
 
 all chat messages in JSQMessage formt
 
*/
@property (strong, nonatomic, readonly) NSOrderedSet *allMessages;

/*
 
 
 */
@property (copy, nonatomic) NSString *chatTitle;

/*
 
*/
@property (nonatomic, assign) NSInteger newMessageCount;

/*
 
 */
@property (nonatomic, assign) NSInteger peopleOnline;

@property (strong, nonatomic, readonly) UIButton *sendButton;
@property (strong, nonatomic, readonly) UIButton *microphoneButton;
@property (strong, nonatomic, readonly) UIButton *attachButton;

@property (strong, nonatomic, readonly) UILabel *titleLabel;
@property (strong, nonatomic, readonly) UILabel *typingLabel;

@property (strong, nonatomic, readonly) NSMutableDictionary *avatarImages;
-(JSQMessage *) messageAtIndexPath:(NSIndexPath *)indexPath;

@end
