/*
  LMChatViewController.h
  KuDoo

  Created by Travis Buttaccio on 6/8/15.
  Copyright (c) 2015 LangueMatch. All rights reserved.
 
  Superclass chat interface. Subclass of JSQMessagesViewController abstract class
*/

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

/*!
 @abstract Default initializer for LMChatViewController. Call to superclass constructor will throw an exception
 
 @param address: the firebase address at which the message data will be stored
        groupId: Appended to the firebase address to make it unique
 
 @returns A LMChatViewController instance
 */
-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId;

/*!
 @abstract The firebase url associated with the current view controller from which it pulls and posts new messages
 */
@property (copy, readonly, nonatomic) NSString *firebaseAddress;

/*!
 @abstract The groupId associated with the current chat; a unique identifier appended to the firebase address to make it unique. Constructed by each group members unique Parse-assigned objectId
 */
@property (copy, readonly, nonatomic) NSString *groupId;

/*!
 @abstract The background image for the chat; Can be set by the user in the 'Settings' section.
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/*!
 @abstract Sets the background color of the chat. Only visible if there is no background image set
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/*!
 @abstract Delegate for the instance
 */
@property (weak, nonatomic) id <LMChatViewControllerDelegate> delegate;

/*!
 @abstract Returns a copy of all the JSQMessages
 */
@property (strong, nonatomic, readonly) NSOrderedSet *allMessages;

/*!
 @abstract Displayed at the top of the chat window in the navigation bar
 */
@property (copy, nonatomic) NSString *chatTitle;

/*!
 @abstract Count of the unread messages. Delegate can be notified of changes to this value when new messages are received
 
 @discussion Used to update the chat table UI
 */
@property (nonatomic, assign) NSInteger newMessageCount;

/*!
 @abstract Count of people in the chat
 
 @discussion Used in forum chat to display the number of people online
 */
@property (nonatomic, assign) NSInteger peopleOnline;

/*!
 @abstract Send button displayed at the bottom right of the chat window
 */
@property (strong, nonatomic, readonly) UIButton *sendButton;

/*!
 @abstract Microphone button displayed at the bottom right of the chat window if there is no text in the text view
 */
@property (strong, nonatomic, readonly) UIButton *microphoneButton;

/*!
 @abstract Paperclip at buttom leeft of chat window. Used to attach media to the message
 */
@property (strong, nonatomic, readonly) UIButton *attachButton;

/*!
 @abstract Updates the title label when a user in the chat begins typing
 
 @param snapshot: Contains data from a Firebase location.
 
 @see FDataSnapshot
 */
-(void) refreshTypingLabelWithSnapshot:(FDataSnapshot *)snapshot;

/*!
 @abstract Updates the title label to include current chat members
 
 @param snapshot: Contains data from a Firebase location.
 
 @see FDataSnapshot
 */
-(void) refreshMemberLabelWithSnapshot:(FDataSnapshot *)snapshot;

/*!
 @abstract Creates a JSQMessage with the given information and adds it to the message list if it does not already exist. If it is a media message, will download the information and store it.
 
 @param message: The message data to construct the JSQMessage
 
 @see JSQMessage
 */
-(void) createMessageWithInfo:(NSDictionary *)message;

/*!
 @abstract Used to send an audio message. Audio message data will be stored on Parse server with address url stored at Firebase location to be downloaded by the receiver
 
 @param url: The internal address of the url
 */
-(void) sendAudioMessageWithUrl:(NSURL *)url;

/*!
 @abstract Used to send an image. Image data will be stored on Parse server with the address url stored in firebase to be downloaded by the receiver
 
 @param image: the image data
 */
-(void) sendPictureMessageWithImage:(UIImage *)image;

/*!
 @abstract Used to send a video message. Video message data will be stored on Parse server with address url stored at Firebase location to be downloaded by the receiver
 
 @param url: The internal address of the url
 */
-(void) sendVideoMessageWithURL:(NSURL *)url;


/*!
 @abstract Return the JSQMessage at the specified indexPath
 */
-(JSQMessage *) messageAtIndexPath:(NSIndexPath *)indexPath;

@end
