//
//  LMChatViewModel.h
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
 *  `LMChatViewModel` is the viewmodel class for a chat view controller which handles configuring the raw data (e.g. messages, images) to make it presentable in the chat window
 *
 *  ## Implementation Notes
 *
 *  
 *
 *  ## Usage Example
 *
 */

@import UIKit;
@class LMChatViewController, JSQMessagesBubbleImage, JSQMessagesAvatarImage, Firebase, FDataSnapshot, JSQMessage;

@interface LMChatViewModel : NSObject

/*!
 @abstract Designated initializer for LMChatViewModel.
 
 @param The view controller associated with the view model
 
  @returns A LMChatViewModel instance
 */
-(instancetype) initWithViewController:(LMChatViewController *)controller;

/*!
 @abstract The view controller associated with the view model
 
 @see LMChatViewController
 */
@property (weak, nonatomic, readonly) LMChatViewController *chatVC;

/*!
 @abstract Outgoing message bubble data. Created from JSQMessagesBubbleImageFactory
 
 @see JSQMessagesBubbleImageFactor
 */
@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingMessageBubble;

/*!
 @abstract Incoming message bubble image. Created from JSQMessagesBubbleImageFactory
 
 @see JSQMessagesBubbleImageFactory
 */
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingMessageBubble;

/*!
 @abstract Blank avatar image used if no data is available. Created from JSQMessagesBubbleImageFactory
 
 @see JSQMessagesBubbleImageFactory
 */
@property (nonatomic, strong) JSQMessagesAvatarImage *placeholderAvatar;

/*!
 @abstract Handles configuring the raw user data to UI readable info
 
 @discussion See LMUserViewModel
 */
@property (nonatomic, assign) BOOL initialized;

/*!
 @abstract Configures a typing label text from a snapshot
 
 @param FDataSnapshot snapshot of the firebase location.
 
 @returns NSString
 
 @see FDataSnapshot
 */
-(NSString *) updateTypingLabelWithSnapshot:(FDataSnapshot *)snapshot;

/*!
 @abstract Configures a member label text from a given snapshot
 
 @param FDataSnapshot snapshot of the firebase location.
 
 @returns NSString
 
 @see FDataSnapshot
 */
-(NSString *) updateMemberLabelWithSnapshot:(FDataSnapshot *)snapshot;

/*!
 @abstract Configures an attributed string with the given parameters
 
 @param essage Current JSQMessage
        previousMessage JSQMessage before message
        indexPath NSIndexPath of the message
 
 @returns NSAttributedString
 
 @discussion Used in LMChatViewController to display the date label. If the messages are from the same day, no label is shown.
 */
-(NSAttributedString *)attributedStringForCellTopLabelFromMessage:(JSQMessage *)message withPreviousMessage:(JSQMessage *)previousMessage forIndexPath:(NSIndexPath *)indexPath;

/*!
 @abstract Helper method to extract data from a given message
 
 @param message raw message data
 
 @returns Configured JSQMessage to be displayed in a JSQMessagesViewController
 
 @see JSQMessagesViewController
 */
-(JSQMessage *) createMessageWithInfo:(NSDictionary *)message;

/*!
 @abstract Helper methods to save and send messages. Once the raw data is saved (if media message) the message info is sent to Firebase.
 
 @discussion Raw media message data is stored on Parse with the urlLocation stored in the message data on firebase
 */
-(void) saveTextMessage:(NSString *)text toFirebase:(Firebase *)firebase;
-(void) savePictureMessage:(UIImage *)picture toFirebase:(Firebase *)firebase;
-(void) saveVideoMessage:(NSURL *)url toFirebase:(Firebase *)firebase;
-(void) saveAudioMessage:(NSURL *)url toFirebase:(Firebase *)firebase;


@end
