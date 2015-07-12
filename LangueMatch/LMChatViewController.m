#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "NSDate+Chats.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMChatViewModel.h"
#import "LMAudioMessageViewController.h"
#import "UIColor+applicationColors.h"
#import "LMAlertControllers.h"
#import "JSQAudioMediaItem.h"
#import "UIButton+TapAnimation.h"
#import "ParseConnection.h"

#import <Firebase/Firebase.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@import MediaPlayer;

@interface LMChatViewController () <NSCoding, LMAudioMessageViewControllerDelegate>

@property (copy, readwrite, nonatomic) NSString *firebaseAddress;
@property (copy, readwrite, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSMutableOrderedSet *messages;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic, readwrite) UILabel *titleLabel;
@property (strong, nonatomic, readwrite) UILabel *typingLabel;
@property (strong, nonatomic, readwrite) UILabel *onlineLabel;

@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) NSUInteger numberOfMessagesToShow;

@property (strong, nonatomic) Firebase *messageFirebase;
@property (strong, nonatomic) Firebase *typingFirebase;
@property (strong, nonatomic) Firebase *memberFirebase;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic) JSQMessagesAvatarImage *placeholderAvatar;
@property (strong, nonatomic, readwrite) NSMutableDictionary *avatarImages;

@property (strong, nonatomic) LMChatViewModel *viewModel;

@property (strong, nonatomic) LMAudioMessageViewController *audioRecorder;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *attachButton;

@property (strong, nonatomic) IDMPhotoBrowser *photoBrowser;

@end

@implementation LMChatViewController

static NSUInteger sectionMessageCountIncrementor = 10;

#pragma mark - View Controller Life Cycle

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        _firebaseAddress = address;
        _groupId = groupId;
        _newMessageCount = 0;
        _viewModel = [[LMChatViewModel alloc] initWithViewController:self];
        
        [self p_setupFirebase];
    }
    return self;
}

-(instancetype) init
{
    [NSException exceptionWithName: @"Use default initilizer" reason:@"Must use designated intializer (initWithFirebase:andGroupId:)" userInfo:nil];
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_messages) {
        self.messages = [[NSMutableOrderedSet alloc] init];
    }
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont lm_robotoLightMessage];
    
    //Need to change JSQMessagesInputToolbar.m toggleSendButtonEnabled to always return YES
    UIImage *microphone = [UIImage imageNamed:@"microphone.png"];
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_microphoneButton setImage:microphone forState:UIControlStateNormal];
    _microphoneButton.backgroundColor = [UIColor lm_cloudsColor];
    [_microphoneButton.layer setCornerRadius:10.0f];
    [_microphoneButton.layer setMasksToBounds:YES];
    [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
    
    _sendButton = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    
    _attachButton = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    [self.inputToolbar.contentView setLeftBarButtonItem:_attachButton];
    
    self.senderDisplayName = [PFUser currentUser][PF_USER_DISPLAYNAME];
    self.senderId = [PFUser currentUser].objectId;
    
    self.outgoingMessageBubble = self.viewModel.outgoingMessageBubble;
    self.incomingMessageBubble = self.viewModel.incomingMessageBubble;
    
    self.showLoadEarlierMessagesHeader = YES;
    self.numberOfMessagesToShow = 10;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.inputToolbar.contentView.textView.font = [UIFont lm_robotoLightMessage];
    
    self.titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel setFont:[UIFont lm_robotoLightLarge]];
    
    self.titleLabel.text = (_chatTitle) ?: self.groupId;
    
    self.typingLabel = [[UILabel alloc] init];
    self.typingLabel.textColor = [UIColor whiteColor];
    [self.typingLabel setFont:[UIFont lm_robotoLightTimestamp]];
    
    self.onlineLabel = [[UILabel alloc] init];
    
    for (UILabel *label in @[self.titleLabel, self.typingLabel]) {
        [self.titleView addSubview:label];
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.navigationItem setTitleView:self.titleView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self scrollToBottomAnimated:NO];
    
    [[self.memberFirebase childByAppendingPath:self.senderId] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
    
    [self.typingFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self refreshTypingLabelWithSnapshot:snapshot];
    }];
    
    [self.memberFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self refreshMemberLabelWithSnapshot:snapshot];
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.memberFirebase updateChildValues:@{self.senderId: @{}}];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CENTER_VIEW_H(_titleView, _titleLabel);
    CENTER_VIEW_H(_titleView, _typingLabel);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(_titleView, _titleLabel, 10);
    ALIGN_VIEW_TOP_CONSTANT(_titleView, _typingLabel, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.messages = nil;
    self.avatarImages = nil;
}

-(void)dealloc
{
    [self.messageFirebase removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - JSQMessagesInputToolbar Delegate

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    UIAlertController *chooseSourceTypeAlert = [LMAlertControllers chooseCameraSourceAlertWithCompletion:^(NSInteger type)
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
        [UIButton lm_animateButtonPush:sender];        
        CGRect recordingFrame = CGRectMake(0, 260, self.inputToolbar.bounds.size.width, 44);
        
        if(!_audioRecorder) {
            self.audioRecorder = [[LMAudioMessageViewController alloc] initWithFrame:recordingFrame];
            self.audioRecorder.delegate = self;
        }
        
        [self.inputToolbar.contentView addSubview:self.audioRecorder.view];
        [self.inputToolbar loadToolbarContentView];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.audioRecorder.view.transform = CGAffineTransformMakeTranslation(0, -260);
        }];
    }
    else
    {
        [self.viewModel sendTextMessage: toolbar.contentView.textView.text];
        AudioServicesPlaySystemSound(1004);
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        [self.typingFirebase updateChildValues:@{self.senderId : @{}}];
        self.isTyping = false;
    }
}


#pragma mark - JSQMessagesViewController Delegate

-(void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSInteger difference = self.messages.count - self.numberOfMessagesToShow;
    
    if (difference > sectionMessageCountIncrementor) {
        self.numberOfMessagesToShow += sectionMessageCountIncrementor;
    } else {
        self.numberOfMessagesToShow += difference;
    }
    
    [self.collectionView reloadData];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[JSQPhotoMediaItem class]])
        {
            [self.viewModel photoIndexForDate:message.date withCompletion:^(NSInteger index) {
                self.photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:self.viewModel.photos];
                self.photoBrowser.displayCounterLabel = YES;
                [self.photoBrowser setInitialPageIndex:index];
                [self presentViewController:self.photoBrowser animated:YES completion:nil];
            }];
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

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (info[UIImagePickerControllerMediaURL]) [self sendVideoMessageWithURL:info[UIImagePickerControllerMediaURL]];
    else [self sendPictureMessageWithImage:info[UIImagePickerControllerEditedImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) sendPictureMessageWithImage:(UIImage *)image
{
    [self.viewModel sendPictureMessage:image];
}

-(void) sendVideoMessageWithURL:(NSURL *)url
{
    [self.viewModel sendVideoMessage:url];
}

#pragma mark - LMAudioMessageViewController Delegate

-(void) audioRecordingController:(LMAudioMessageViewController *)controller didFinishRecordingWithContents:(NSURL *)url
{
    [self sendAudioMessageWithUrl:url];
    [self cancelAudioRecorder:controller];
}

-(void) sendAudioMessageWithUrl:(NSURL *)url
{
    [self.viewModel sendAudioMessage:url];
}

-(void) cancelAudioRecorder:(LMAudioMessageViewController *)controller
{
    [UIView animateWithDuration:0.5f animations:^{
        self.audioRecorder.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - JSQMessagesCollectionView Data Source

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageAtIndexPath:indexPath];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingMessageBubble;
    }
    
    return self.incomingMessageBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_avatarImages) {
        self.avatarImages = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.avatarImages objectForKey:senderId]) return [JSQMessagesAvatarImageFactory avatarImageWithImage:[self.avatarImages objectForKey:senderId] diameter:30.0f];
    
    if (!_placeholderAvatar) {
        self.placeholderAvatar = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"?" backgroundColor:[UIColor lightGrayColor] textColor:[UIColor whiteColor] font:[UIFont lm_robotoLightMessage] diameter:30.0f];
    }
    
    PFUser *user = [PFUser objectWithoutDataWithObjectId:senderId];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedUser, NSError *error) {
        PFFile *thumbnailFile = [fetchedUser objectForKey:PF_USER_THUMBNAIL];
        [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            [self.avatarImages setValue:image forKey:senderId];
            [self.collectionView reloadData];
        }];
    }];
    
    return self.placeholderAvatar;
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 15;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *dateString = [NSString lm_dateToStringShortTimeOnly:message.date];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor lm_wetAsphaltColor]};
    
    return [[NSAttributedString alloc] initWithString:dateString attributes:attributes];
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self messageAtIndexPath:indexPath];
    JSQMessage *previousMessage = nil;
    
    if (indexPath.item > 0) {
        NSIndexPath *previous = [NSIndexPath indexPathForItem:(indexPath.item - 1) inSection:indexPath.section];
        previousMessage = ([self messageAtIndexPath:previous]) ?: nil;
    }
    
    return [self.viewModel attributedStringForCellTopLabelFromMessage:currentMessage withPreviousMessage:previousMessage forIndexPath:indexPath];
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath]) {
        return 30;
    }
    
    return 0;
}


#pragma mark - UICollectionView Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.messages.count < self.numberOfMessagesToShow) {
        return self.messages.count;
    }
    
    return self.numberOfMessagesToShow;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor lm_wetAsphaltColor];
    } else {
        cell.textView.textColor = [UIColor whiteColor];
    }

    return cell;
}

#pragma mark - TextField Delegate

-(void)textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    if (self.isTyping == false && textView.text.length > 0) {
        [[self.typingFirebase childByAppendingPath:self.senderId] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
        [self.inputToolbar.contentView setRightBarButtonItem:_sendButton];
        self.isTyping = true;
    } else if (self.isTyping == true && textView.text.length == 0) {
        [self.typingFirebase updateChildValues:@{self.senderId : @{}}];
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        self.isTyping = false;
    }
}


#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.messages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messages))];
//        self.avatarImages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarImages))];
        self.firebaseAddress = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebaseAddress))];
        self.groupId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(groupId))];
        self.titleView = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(titleView))];
        self.titleLabel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(titleLabel))];
        self.chatTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatTitle))];
        self.viewModel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(viewModel))];
        
    } else {
        return nil;
    }
    
    self.newMessageCount = 0;
    self.viewModel.chatVC = self;
    if (self.messages.count != 0) self.viewModel.initialized = YES;
    [self p_setupFirebase];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.messages forKey:NSStringFromSelector(@selector(messages))];
//    [aCoder encodeObject:self.avatarImages forKey:NSStringFromSelector(@selector(avatarImages))];
    [aCoder encodeObject:self.firebaseAddress forKey:NSStringFromSelector(@selector(firebaseAddress))];
    [aCoder encodeObject:self.groupId forKey:NSStringFromSelector(@selector(groupId))];
    [aCoder encodeObject:self.titleView forKey:NSStringFromSelector(@selector(titleView))];
    [aCoder encodeObject:self.titleLabel forKey:NSStringFromSelector(@selector(titleLabel))];
    [aCoder encodeObject:self.chatTitle forKey:NSStringFromSelector(@selector(chatTitle))];
    [aCoder encodeObject:self.viewModel forKey:NSStringFromSelector(@selector(viewModel))];

}

#pragma mark - Private Methods

-(void) p_setupFirebase
{
    [self p_registerForApplicationStateNotifications];
    
    [self.viewModel setupFirebasesWithAddress:self.firebaseAddress andGroupId:self.groupId];
    
    self.memberFirebase = self.viewModel.memberFirebase;
    self.typingFirebase = self.viewModel.typingFirebase;
    self.messageFirebase = self.viewModel.messageFirebase;
}

-(void) createMessageWithInfo:(NSDictionary *)message
{
    JSQMessage *jsqMessage = [self.viewModel createMessageWithInfo:message];
    
    if (jsqMessage != nil) {
        
        [self.messages addObject:jsqMessage];
        if ([self.delegate respondsToSelector:@selector(lastMessage:forChat:)]) [self.delegate lastMessage:message forChat:self.groupId];
        
        self.newMessageCount++;
        if ([self.delegate respondsToSelector:@selector(incrementedNewMessageCount:ForChat:)]) [self.delegate incrementedNewMessageCount:self.newMessageCount ForChat:self.groupId];
        
        if (![jsqMessage.senderId isEqualToString:self.senderId]) {
            
            if ([jsqMessage isMediaMessage]) {
                JSQMediaItem *mediaItem = (JSQMediaItem *)jsqMessage.media;
                mediaItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            [self finishReceivingMessageAnimated:YES];
        } else {
            [self finishSendingMessageAnimated:YES];
        }
    }
}

-(void) refreshTypingLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSString *typingText = [self.viewModel updateTypingLabelWithSnapshot:snapshot];
    if ([typingText isEqualToString:@""]) [self.typingLabel setText:_onlineLabel.text];
    else [self.typingLabel setText:typingText];
    if ([self.delegate respondsToSelector:@selector(peopleTypingText:)]) [self.delegate peopleTypingText:self.typingLabel.text];
    [self p_updateTitlePosition];
}

-(void) refreshMemberLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    NSString *onlineText = [self.viewModel updateMemberLabelWithSnapshot:snapshot];
    [_onlineLabel setText:onlineText];
    if ([_typingLabel.text isEqualToString:@""]) [self.typingLabel setText:onlineText];
    if ([onlineText isEqualToString:@""]) [self.typingLabel setText:@""];
    else if ([self.delegate respondsToSelector:@selector(numberOfPeopleOnline:changedForChat:)]) [self.delegate numberOfPeopleOnline:snapshot.childrenCount changedForChat:self.groupId];
    [self p_updateTitlePosition];
}

-(void) p_updateTitlePosition
{
    if (self.typingLabel.text.length == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            self.titleLabel.transform = CGAffineTransformIdentity;
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.titleLabel.transform = CGAffineTransformMakeTranslation(0, -10);
        }];
    }
}

-(JSQMessage *) messageAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger path = indexPath.item;
    NSUInteger items = self.messages.count;
    
    if (self.numberOfMessagesToShow > self.messages.count)
        return self.messages[path];
    
    return self.messages[(items - self.numberOfMessagesToShow) + path];
}

#pragma mark - Setter Methods
-(void) setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
}

-(void) setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [backgroundView setImage:backgroundImage];
    self.collectionView.backgroundView = backgroundView;
}

-(void) setChatTitle:(NSString *)chatTitle
{
    _chatTitle = chatTitle;
    self.titleLabel.text = chatTitle;
}

#pragma mark - Getter Methods
-(NSOrderedSet *) allMessages
{
    return [self.messages copy];
}

#pragma mark - Notifications

-(void) p_registerForApplicationStateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.typingFirebase updateChildValues:@{self.senderId : @{}}];
        [self.memberFirebase updateChildValues:@{self.senderId: @{}}];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.typingFirebase updateChildValues:@{self.senderId : @{}}];
        [self.memberFirebase updateChildValues:@{self.senderId: @{}}];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (self.navigationController.topViewController == self) {
            [[self.memberFirebase childByAppendingPath:self.senderId] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
            [self.typingFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                [self.viewModel updateTypingLabelWithSnapshot:snapshot];
            }];
            
            [self.memberFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                [self.viewModel updateMemberLabelWithSnapshot:snapshot];
            }];
        }
    }];
}


@end