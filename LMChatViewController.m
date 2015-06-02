//
//  LMChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

@import MediaPlayer;

#import "LMChatViewController.h"
#import "LMAlertControllers.h"
#import "AppConstant.h"
#import "LMData.h"
#import "LMParseConnection+Chats.h"
#import "LMAudioMessageViewController.h"
#import "JSQAudioMediaItem.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>
#import <JSQMessages.h>

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface LMChatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, JSQMessagesInputToolbarDelegate, LMAudioMessageViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *JSQmessages;
@property (strong, nonatomic) NSMutableArray *LMMessages;

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageIncoming;

@property (strong, nonatomic) UIImage *chatImage;

@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *attachButton;
@property (strong, nonatomic) LMAudioMessageViewController *audioVC;

@property (assign, nonatomic) BOOL isTyping;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation LMChatViewController

const NSInteger numberOfMessagesPerSection = 5;

-(instancetype) initWithChat:(PFObject *)chat
{
    if (self = [super init]) {
        _chat = chat;
        
        // Need cache mechanism in between application launches
        [self p_getChatImage];
        [self p_getChatMessagesFromLocalDataStore];
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_renderBackgroundColor];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    _bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lm_orangeColor]];
    _bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor lm_tealBlueColor]];
    
    self.senderDisplayName = [PFUser currentUser].username;
    self.senderId = [PFUser currentUser].objectId;
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.showLoadEarlierMessagesHeader = YES;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont lm_noteWorthyMedium];
    
    //Need to override inputToolbar.toggleSendButtonEnabled in source file to always be yes
    
    UIImage *microphone = [UIImage imageNamed:@"record.png"];
    _microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_microphoneButton setImage:microphone forState:UIControlStateNormal];
    [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];

    UIImage *attach = [UIImage imageNamed:@"lights.png"];
    _attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_attachButton setImage:attach forState:UIControlStateNormal];
    [self.inputToolbar.contentView setLeftBarButtonItem:_attachButton];
    
    _sendButton = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    self.titleLabel.font = [UIFont lm_noteWorthyMedium];
    self.titleLabel.text = self.chat[PF_CHAT_TITLE];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = self.titleLabel;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Chats" style:UIBarButtonItemStylePlain target:self action:@selector(userPressedBackButton:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark - JSQMessagesCollectionViewDataSource

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self p_getMessageFromIndexPath:indexPath];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.bubbleImageOutgoing;
    }
    
    return self.bubbleImageIncoming;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return ceil((double)[self messageList].count/numberOfMessagesPerSection);
//}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return [self messageList].count % numberOfMessagesPerSection;
//    }
//    
    return self.JSQmessages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId])
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    
    JSQMessagesTimestampFormatter *timeFormatters = [JSQMessagesTimestampFormatter sharedFormatter];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.firstLineHeadIndent = 20.0f;
    
    NSDictionary *dateTextAttributes = @{ NSFontAttributeName : [UIFont lm_noteWorthyLightTimeStamp],
                             NSForegroundColorAttributeName : [UIColor lm_cloudsColor],
                             NSParagraphStyleAttributeName : paragraphStyle};
    
    if ([message.senderId isEqualToString:self.senderId]) {
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.tailIndent = -20.0f;
    }
    else paragraphStyle.alignment = NSTextAlignmentLeft;
    
    [timeFormatters setDateTextAttributes:dateTextAttributes];
    [timeFormatters setTimeTextAttributes:dateTextAttributes];
    NSString *timeStamp = [timeFormatters timeForDate:message.date];
    
    NSMutableAttributedString *attributedTime = [[NSMutableAttributedString alloc] initWithString:timeStamp attributes:dateTextAttributes];
    
    return attributedTime;
}
 
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return nil;
    }
    
    if (indexPath.item - 1 > 0)
    {
        NSUInteger previousMessageIndex = [self.JSQmessages indexOfObject:message] - 1;
        JSQMessage *previousMessage = [self.JSQmessages objectAtIndex:previousMessageIndex];
        
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *currentMessage = [self p_getMessageFromIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDoesRelativeDateFormatting:YES];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *dateTextAttributes = @{ NSFontAttributeName : [UIFont lm_noteWorthySmall],
                                          NSForegroundColorAttributeName : [UIColor whiteColor],
                                          NSParagraphStyleAttributeName : paragraphStyle};
    
    NSString *currentMessageDate;
    
    if (indexPath.item == 0) {
        currentMessageDate = [formatter stringFromDate:currentMessage.date];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:currentMessageDate attributes:dateTextAttributes];
        
        return attributedString;
    }
    
    if (indexPath.item - 1 > 0)
    {
        
        NSUInteger previousMessageIndex = [self.JSQmessages indexOfObject:currentMessage] - 1;
        JSQMessage *previousMessage = [self.JSQmessages objectAtIndex:previousMessageIndex];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
        
        currentMessageDate = [dateFormatter stringFromDate:currentMessage.date];
        NSString *previousMessageDate = [dateFormatter stringFromDate:previousMessage.date];
        
        if (![currentMessageDate compare:previousMessageDate] == NSOrderedSame)
        {
            currentMessageDate = [formatter stringFromDate:currentMessage.date];
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:currentMessageDate attributes:dateTextAttributes];
            
            return attributedString;
        }
    }
    return nil;
}

#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return 0;
    }
    
    if (indexPath.item - 1 > 0)
    {
        NSUInteger previousMessageIndex = [self.JSQmessages indexOfObject:message] - 1;
        JSQMessage *previousMessage = [self.JSQmessages objectAtIndex:previousMessageIndex];
        
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return 0;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath

{
    return 10;
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath]) {
        return 30;
    }
    
    return 0;
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_getMessageFromIndexPath:indexPath];
    
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[JSQPhotoMediaItem class]])
        {
            JSQPhotoMediaItem *mediaItem = (JSQPhotoMediaItem *)message.media;
            NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
            IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            photoBrowser.useWhiteBackgroundColor = NO;
            photoBrowser.usePopAnimation = NO;
            [self presentViewController:photoBrowser animated:YES completion:nil];
        }
        
        if ([message.media isKindOfClass:[JSQVideoMediaItem class]])
        {
            JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)message.media;
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        }
        
        if ([message.media isKindOfClass:[JSQAudioMediaItem class]])
        {
            JSQAudioMediaItem *mediaItem = (JSQAudioMediaItem *)message.media;
            [mediaItem play];
        }
    }
}


#pragma mark - Touch Handling

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    UIAlertController *chooseSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger type)
                                                {
                                                    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
                                                    
                                                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                        imagePickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                                                    }
                                                    imagePickerVC.allowsEditing = YES;
                                                    imagePickerVC.delegate = self;
                                                    imagePickerVC.sourceType = type;
                                                    [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
                                                }];
    
    [self presentViewController:chooseSourceTypeAlert animated:YES completion:nil];
}

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    if (sender == _microphoneButton)
    {
        CGRect recordingFrame = CGRectMake(0, 44, self.inputToolbar.bounds.size.width, 44);
        
        if(!_audioVC) {
            self.audioVC = [[LMAudioMessageViewController alloc] initWithFrame:recordingFrame];
            self.audioVC.delegate = self;
        }
        
        [self.inputToolbar.contentView addSubview:self.audioVC.view];
        [self.inputToolbar loadToolbarContentView];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.audioVC.view.transform = CGAffineTransformMakeTranslation(0, -44);
        }];
    }
    else
    {
        [self p_sendMessageWithText:toolbar.contentView.textView.text image:nil audio:nil video:nil];
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
    }
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 1)
    {
        if (self.isTyping == NO) {
            if (self.chat.objectId) [LMParseConnection sendTypingNotificationForChat:self.chat currentlyTyping:YES];
            [self.inputToolbar.contentView setRightBarButtonItem:_sendButton];
            self.isTyping = YES;
        }
    }
    else if (textView.text.length == 0)
    {
        if (self.chat.objectId) [LMParseConnection sendTypingNotificationForChat:self.chat currentlyTyping:NO];
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        self.isTyping = NO;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.chat.objectId) [LMParseConnection sendTypingNotificationForChat:self.chat currentlyTyping:NO];
    self.isTyping = NO;
}

-(void)tappedChatImageView:(UIGestureRecognizer *)gesture
{
    NSArray *photos = [IDMPhoto photosWithImages:@[_chatImage]];
    IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:self.navigationController.navigationBar];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - LMAudioMessageViewController Delegate

-(void) audioRecordingController:(LMAudioMessageViewController *)controller didFinishRecordingWithContents:(NSURL *)url
{
    [self p_sendMessageWithText:nil image:nil audio:url video:nil];
    [self cancelAudioRecorder:controller];
}

-(void) cancelAudioRecorder:(LMAudioMessageViewController *)controller
{
    [UIView animateWithDuration:0.5 animations:^{
        self.audioVC.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UIImagePickerSource Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (info[UIImagePickerControllerMediaURL])
    {
        [self p_sendMessageWithText:nil image:nil audio:nil video:info[UIImagePickerControllerMediaURL]];
    }
    
    if (info[UIImagePickerControllerEditedImage])
    {
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        [self p_sendMessageWithText:nil image:selectedImage audio:nil video:nil];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

-(NSArray *) messageList
{
    return _JSQmessages;
}

-(JSQMessage *) p_getMessageFromIndexPath:(NSIndexPath *)indexPath
{
    NSInteger nextCell;
    NSInteger messageCountInFirstSection = [self messageList].count % numberOfMessagesPerSection;
    
    if (indexPath.section == 0) {
        nextCell = indexPath.item;
    } else {
        nextCell = messageCountInFirstSection + (indexPath.section - 1)*numberOfMessagesPerSection + indexPath.item;
    }
    
    return _JSQmessages[indexPath.item];
}

-(void) p_sendMessageWithText:(NSString *)text image:(UIImage *)image audio:(NSURL *)audio video:(NSURL *)video
{
    if (!_JSQmessages)
    {
        self.JSQmessages = [NSMutableArray array];
    }
    
    JSQMessage *jsqMessage;
    
    PFObject *message = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    PFUser *currentUser = [PFUser currentUser];
    message[PF_MESSAGE_USER] = currentUser;
    message[PF_MESSAGE_SENDER_NAME] = self.senderDisplayName;
    message[PF_MESSAGE_SENDER_ID] = self.senderId;
    message[PF_MESSAGE_GROUPID] = self.chat[PF_CHAT_GROUPID];
    [message setObject:self.chat forKey:PF_CHAT_CLASS_NAME];
    
    
    if (text)
    {
        jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:text];
        message[PF_CHAT_TEXT] = text;
    }
    else if (image)
    {
        JSQPhotoMediaItem *photoMedia = [[JSQPhotoMediaItem alloc] initWithImage:image];
        jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:photoMedia];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        PFFile *imageFile = [PFFile fileWithName:@"picture" data:imageData];
        message[PF_MESSAGE_IMAGE] = imageFile;
    }
    else if (audio)
    {
        JSQAudioMediaItem *audioMedia = [[JSQAudioMediaItem alloc] initWithFileURL:audio isReadyToPlay:YES];
        jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:audioMedia];
        
        NSData *audioData = [[NSData alloc] initWithContentsOfURL:audio];
        PFFile *audioFile = [PFFile fileWithName:@"audio.m4a" data:audioData];
        message[PF_MESSAGE_AUDIO] = audioFile;
    }
    else if (video)
    {
        JSQVideoMediaItem *videoMedia = [[JSQVideoMediaItem alloc] initWithFileURL:video isReadyToPlay:YES];
        jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:videoMedia];
        
        NSData *videoData = [[NSData alloc] initWithContentsOfURL:video];
        PFFile *videoFile = [PFFile fileWithName:@"video.mp4" data:videoData];
        message[PF_MESSAGE_VIDEO] = videoFile;
    }
    
    [LMParseConnection saveMessage:message withCompletion:^(BOOL succeeded, NSError *error)
     {
         [self.LMMessages addObject:message];
         [message pinInBackground];
         [self.JSQmessages addObject:jsqMessage];
         [self finishSendingMessageAnimated:YES];
         [self p_setLastMessage];
         [self textViewDidChange:self.inputToolbar.contentView.textView];
     }];
}


-(void) p_getChatImage
{
    if (!_chatImage) {
        PFFile *chatImageData = _chat[PF_CHAT_PICTURE];
        [chatImageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _chatImage = [UIImage imageWithData:data];
                UIImageView *chatImageView = [[UIImageView alloc] initWithImage:_chatImage];
                chatImageView.contentMode = UIViewContentModeScaleAspectFill;
                chatImageView.frame = CGRectMake(0, 0, 35, 35);
                [chatImageView.layer setCornerRadius:10.0f];
                [chatImageView.layer setMasksToBounds:YES];
                
                UIBarButtonItem *chatImageButton = [[UIBarButtonItem alloc] initWithCustomView:chatImageView];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedChatImageView:)];
                tapGesture.delegate = self;
                chatImageView.userInteractionEnabled = YES;
                [chatImageView addGestureRecognizer:tapGesture];
                
                [self.navigationItem setRightBarButtonItem:chatImageButton];
            });
        }];
    }
}

-(void)p_getChatMessagesFromLocalDataStore
{
    if (!_LMMessages && self.chat.objectId)
    {
        [LMParseConnection getMessagesForChat:self.chat fromDatasStore:YES withCompletion:^(NSArray *messages, NSError *error) {
            
            self.LMMessages = [NSMutableArray arrayWithArray:messages];
            
            if (messages.count == 0) {
                
                [self p_checkForNewMessagesFromServer];
            } else {
                
                for (PFObject *LMMessage in _LMMessages)
                {
                    [self p_createJSQMessageFromLMMessage:LMMessage];
                }
                
                [self p_setLastMessage];
                [self p_checkForNewMessagesFromServer];
            }
        }];
    }
}

-(void)p_checkForNewMessagesFromServer
{
    [LMParseConnection getMessagesForChat:self.chat fromDatasStore:NO withCompletion:^(NSArray *messages, NSError *error) {
        
        PFObject *lastCachedChat = self.LMMessages.lastObject;
        
        for (PFObject *message in messages)
        {
            if (![self.LMMessages containsObject:message] && message.createdAt > lastCachedChat.createdAt)
            {
                [self p_createJSQMessageFromLMMessage:message];
                [self.LMMessages addObject:message];
                [message pinInBackground];
            }
        }
        [self p_setLastMessage];
    }];
}

-(void) p_setLastMessage
{
    [self.delegate lastMessage:self.LMMessages.lastObject forChat:self.chat];
}

-(void) p_createJSQMessageFromLMMessage:(PFObject *)message
{
    if (!_JSQmessages) {
        _JSQmessages = [NSMutableArray array];
    }
    
    JSQMessage *jsqMessage;
    
    JSQMessage *lastMessage = [_JSQmessages lastObject];
    if (![lastMessage.date isEqualToDate:message.updatedAt])
    {
        if (message[PF_MESSAGE_IMAGE])
        {
            __block JSQPhotoMediaItem *photoMedia = [[JSQPhotoMediaItem alloc] initWithImage:nil];
            jsqMessage = [[JSQMessage alloc] initWithSenderId:message[PF_MESSAGE_SENDER_ID] senderDisplayName:message[PF_MESSAGE_SENDER_NAME] date:message.updatedAt media:photoMedia];
            
            PFFile *chatImageData = message[PF_MESSAGE_IMAGE];
            [chatImageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *messageImage = [UIImage imageWithData:data];
                    photoMedia.image =  messageImage;
                    if (![message[PF_MESSAGE_SENDER_ID] isEqualToString:self.senderId])
                    {
                        photoMedia.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    [self.collectionView reloadData];
                });
            }];
        }
        
        else if (message[PF_MESSAGE_TEXT])
        {
            jsqMessage = [[JSQMessage alloc] initWithSenderId:message[PF_MESSAGE_SENDER_ID] senderDisplayName:message[PF_MESSAGE_SENDER_NAME] date:message.updatedAt text:message[PF_MESSAGE_TEXT]];
        }
        
        else if (message[PF_MESSAGE_AUDIO])
        {
            PFFile *audioFile = message[PF_MESSAGE_AUDIO];
            JSQAudioMediaItem *audioMedia = [[JSQAudioMediaItem alloc] initWithFileURL:[NSURL URLWithString:audioFile.url] isReadyToPlay:YES];

            audioMedia.appliesMediaViewMaskAsOutgoing = [message[PF_MESSAGE_SENDER_ID] isEqualToString:self.senderId];
            jsqMessage = [[JSQMessage alloc] initWithSenderId:message[PF_MESSAGE_SENDER_ID] senderDisplayName:message[PF_MESSAGE_SENDER_NAME] date:message.updatedAt media:audioMedia];
        }
        else if (message[PF_MESSAGE_VIDEO])
        {
            PFFile *videoFile = message[PF_MESSAGE_VIDEO];
            JSQVideoMediaItem *videoMedia = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:videoFile.url] isReadyToPlay:YES];
            videoMedia.appliesMediaViewMaskAsOutgoing = [message[PF_MESSAGE_SENDER_ID] isEqualToString:self.senderId];
            jsqMessage = [[JSQMessage alloc] initWithSenderId:message[PF_MESSAGE_SENDER_ID] senderDisplayName:message[PF_MESSAGE_SENDER_NAME] date:message.updatedAt media:videoMedia];
        }
    }
    
    [self.JSQmessages addObject:jsqMessage];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
}

-(void) p_renderBackgroundColor
{
    // Noy sure we want this - adds parallax to chat view
    
    CGSize collectionViewSize = self.collectionView.frame.size;
//
//    UIInterpolatingMotionEffect *verticalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.y"
//     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    verticalMotionEffect.minimumRelativeValue = @(-10);
//    verticalMotionEffect.maximumRelativeValue = @(10);
//    
//    // Set horizontal effect
//    UIInterpolatingMotionEffect *horizontalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.x"
//     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    horizontalMotionEffect.minimumRelativeValue = @(-10);
//    horizontalMotionEffect.maximumRelativeValue = @(10);
//    
//    // Create group to combine both
//    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
//    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
//    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, collectionViewSize.width + 80, collectionViewSize.height + 100)];
    backgroundView.backgroundColor = [UIColor lm_wetAsphaltColor];
//    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
//    backgroundView.image = [UIImage imageNamed:@"dessertSunset.jpg"];
//    
//    [backgroundView addMotionEffect:group];
//    
    self.collectionView.backgroundView = backgroundView;
}

#pragma mark - Delegate Methods

-(void) userPressedBackButton:(UIBarButtonItem *)sender
{
    [self.inputToolbar endEditing:YES];
    [self.delegate userEndedChat:_chat];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Receiving Messages


-(void) receivedNewMessage:(PFObject *)message
{
    [message pinInBackground];
    [self p_createJSQMessageFromLMMessage:message];
    [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    [self finishReceivingMessageAnimated:YES];
    [self.LMMessages addObject:message];
    [self p_setLastMessage];
}

-(void) userIsTyping:(NSString *)username
{
    self.titleLabel.numberOfLines = 2;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ is typing...", username];
}

-(void) userStoppedTyping:(NSString *)username
{
    self.titleLabel.text = self.chat[PF_CHAT_TITLE];
}

@end
