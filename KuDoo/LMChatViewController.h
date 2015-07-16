//
//  LMChatViewController.h
//
//
//  Copyright (c) 2015 Travis Buttaccio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

/**
 *  `LMChatViewController` is a superclass chat interface and a subclass of JSQMessagesViewController
 *
 *  ## Implementation Notes
 *
 *  'LMChatViewController' is subclassed in KuDoo for private, group and forum chats
 *
 *  ## Usage Example
 *
 *  With a firebase and Parse account setup, this view controller can be plugged into an app to provide a real-time chat application interface
 *  The uperclass sender Id is automatically set to [PFUser currentUser].objectId
 */

#import <JSQMessagesViewController/JSQMessages.h>
@class Firebase, FDataSnapshot, IDMPhoto, LMChatViewController;

@protocol LMChatViewControllerDelegate <NSObject>

@optional

/*!
 @discussion Used to show last chat message in table view
 */
-(void) updateLastMessage:(NSDictionary *)message forChatViewController:(LMChatViewController *)controller;

/*!
 @discussion Used to badge the tab bar icon when new messages appear
 */
-(void) incrementNewMessageCount:(NSInteger)messageCount forChatViewController:(LMChatViewController *)controller;

/*!
 @abstract Called whenever the number of people change in the chat room
 */
-(void) numberOfPeopleOnlineChanged:(NSInteger)peopleCount forChatViewController:(LMChatViewController *)controller;

@end

@interface LMChatViewController : JSQMessagesViewController <NSCoding, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JSQMessagesInputToolbarDelegate>

/*!
 @abstract Default initializer for LMChatViewController. Call to superclass constructor will throw an exception
 
 @param address: the firebase address at which the message data will be stored
        groupId: Appended to the firebase address to make it unique
 
 @returns A LMChatViewController instance
 */
-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId;

/*!
 @abstract Delegate called when changes within the chat occur
 
 @discussion Used in KuDoo to update UI for private and forum chat table view controllers
 */
@property (nonatomic, weak) id <LMChatViewControllerDelegate> delegate;

/*!
 @abstract The firebase url associated with the current view controller from which it pulls and posts new messages
 
 @discussion Three firebase locations are initialized at this base address: One each for messages, people and typing to dynamically update UI
 */
@property (nonatomic, copy, readonly) NSString *firebaseAddress;

/*!
 @abstract The groupId associated with the current chat; a unique identifier appended to the firebase address to make it unique. Constructed by each group members unique Parse-assigned objectId
 */
@property (nonatomic, copy, readonly) NSString *groupId;

/*!
 @abstract The background image for the chat; Can be set by the user in the 'Settings' section.
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/*!
 @abstract Sets the background color of the chat. Only visible if there is no background image set
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/*!
 @abstract Returns a copy of all the JSQMessages
 
 @see JSQMessages
 */
@property (nonatomic, copy, readonly) NSOrderedSet *allMessages;

/*!
 @abstract Send button displayed at the bottom right of the chat window
 
 @discussion Appears when there is text in the JSQMessagesInput Text View
 */
@property (nonatomic, strong, readonly) UIButton *sendButton;

/*!
 @abstract Microphone button displayed at the bottom right of the chat window if there is no text in the text view. Used to record and send audio messages
 
 @discussion Default image: Appears if there is not text within the text view. When pressed an audio recording dashboard pops up from the bottom
 */
@property (nonatomic, strong, readonly) UIButton *microphoneButton;

/*!
 @abstract Paperclip at buttom leeft of chat window. Used to attach media to the message
 
 @discussion Used to attach photos and video to a message
 */
@property (nonatomic, strong, readonly) UIButton *attachButton;

/*!
 @abstract Current count of people in the chat room
 
 @discussion Same as the last call to corresponding delegate method
 */
@property (nonatomic, readonly) NSInteger peopleOnline;

/*!
 @abstract Number of unread messages. When view appears or disappears the value is reset to zero
 
 @discussion Same as the last call to corresponding delegate method
 */
@property (nonatomic, readonly) NSInteger newMessageCount;

/*!
 @abstract Title label displays the title of the chat shown in the navigation bar above chat window
 */
@property (nonatomic, strong) UILabel *titleLabel;

/*!
 @abstract Detail label is just below the title lable in the navigation bar
 
 @discussion Used by KuDoo to display if someone is typing, or else the users in the chat room
 */
@property (nonatomic, strong) UILabel *typingLabel;

/*!
 @abstract Maximum number of messages pulled from firebase location when initialized. Number MUST be greater than 0;
 
 @discussion Default is 10. Use 10 for forum chats and 1 for private chats.
 */
@property (nonatomic, assign) NSUInteger numberOfMessagesToQuery;

/*!
 @abstract Stores the photo internally as an IDMPhoto to be viewed in a IDMPhotoViewer when user taps on a picture message
 
 @discussion Used by view model once image data is finished downloading from Parse
 */
-(void) storeImage:(UIImage *)image forDate:(NSDate *)date;

/*!
 @abstract Sends audio message from [PFUser currentUser]
 
 @param Url of the audio message on disk
 
 @discussion Can be overriden by subclasses to customize behavior after sending a messge
 */
-(void) sendAudioMessageWithUrl:(NSURL *)url;

/*!
 @abstract Sends picture message from [PFUser currentUser]
 
 @param image to send
 
 @discussion Can be overriden by subclasses to customize behavior after sending a messge
 */
-(void) sendPictureMessageWithImage:(UIImage *)image;

/*!
 @abstract Sends audio message from [PFUser currentUser]
 
 @param Url of the video message on disk
 
 @discussion Can be overriden by subclasses to customize behavior after sending a messge
 */
-(void) sendVideoMessageWithURL:(NSURL *)url;

/*!
 @abstract Return the JSQMessage at the specified indexPath
 */
-(JSQMessage *) messageAtIndexPath:(NSIndexPath *)indexPath;

@end
