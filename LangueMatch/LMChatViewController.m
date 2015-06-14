#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "NSDate+Chats.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMUserProfileViewController.h"
#import "LMChatViewModel.h"
#import "LMAudioMessageViewController.h"
#import "LMAlertControllers.h"
#import "JSQAudioMediaItem.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@import MediaPlayer;

@interface LMChatViewController () <NSCoding, LMAudioMessageViewControllerDelegate>

@property (strong, readwrite, nonatomic) NSString *firebaseAddress;
@property (strong, readwrite, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSMutableOrderedSet *messages;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *typingLabel;

@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) NSUInteger numberOfMessagesToShow;

@property (strong, nonatomic) Firebase *messageFirebase;
@property (strong, nonatomic) Firebase *typingFirebase;
@property (strong, nonatomic) Firebase *memberFirebase;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic) JSQMessagesAvatarImage *placeholderAvatar;
@property (strong, nonatomic) NSMutableDictionary *avatarImages;

@property (strong, nonatomic) LMChatViewModel *viewModel;

@property (strong, nonatomic) LMAudioMessageViewController *audioRecorder;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *attachButton;

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
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!_messages) {
        self.messages = [[NSMutableOrderedSet alloc] init];
    }
    
    //Need to change JSQMessagesInputToolbar.m toggleSendButtonEnabled to always return YES
    
    UIImage *microphone = [UIImage imageNamed:@"microphone.png"];
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_microphoneButton setImage:microphone forState:UIControlStateNormal];
    [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
    
    _sendButton = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    
    _attachButton = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    [self.inputToolbar.contentView setLeftBarButtonItem:_attachButton];
    
    self.senderDisplayName = [PFUser currentUser].username;
    self.senderId = [PFUser currentUser].objectId;
    
    self.outgoingMessageBubble = self.viewModel.outgoingMessageBubble;
    self.incomingMessageBubble = self.viewModel.incomingMessageBubble;
    
    self.showLoadEarlierMessagesHeader = YES;
    self.numberOfMessagesToShow = 10;
    
    self.titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont lm_noteWorthyMedium]];
    
    self.titleLabel.text = (_chatTitle) ?: self.groupId;
    
    self.typingLabel = [[UILabel alloc] init];
    [self.typingLabel setFont:[UIFont lm_noteWorthyLightTimeStamp]];
    
    for (UILabel *label in @[self.titleLabel, self.typingLabel]) {
        [self.titleView addSubview:label];
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.navigationItem setTitleView:self.titleView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.inputToolbar toggleSendButtonEnabled];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self.memberFirebase childByAppendingPath:self.senderId] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputToolbar endEditing:YES];
    [self.memberFirebase updateChildValues:@{self.senderId: @{}}];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CENTER_VIEW_H(_titleView, _titleLabel);
    CENTER_VIEW_H(_titleView, _typingLabel);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(_titleView, _titleLabel, 0);
    ALIGN_VIEW_TOP_CONSTANT(_titleView, _typingLabel, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.messages = nil;
}

-(void)dealloc
{
    [self.messageFirebase removeAllObservers];
}

#pragma mark - JSQMessagesInputToolbar Delegate

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
        
        if(!_audioRecorder) {
            self.audioRecorder = [[LMAudioMessageViewController alloc] initWithFrame:recordingFrame];
            self.audioRecorder.delegate = self;
        }
        
        [self.inputToolbar.contentView addSubview:self.audioRecorder.view];
        [self.inputToolbar loadToolbarContentView];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.audioRecorder.view.transform = CGAffineTransformMakeTranslation(0, -44);
        }];
    }
    else
    {
        [self.viewModel sendTextMessage: toolbar.contentView.textView.text];
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
        self.isTyping = false;
    }
}


#pragma mark - JSQMessagesViewController Delegate

-(void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSUInteger difference = self.messages.count - self.numberOfMessagesToShow;
    
    if (difference > sectionMessageCountIncrementor) {
        self.numberOfMessagesToShow += sectionMessageCountIncrementor;
    } else {
        self.numberOfMessagesToShow += difference;
    }
    
    [self.collectionView reloadData];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    LMUserProfileViewController *profileVC = [[LMUserProfileViewController alloc] initWithUserId:senderId];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    
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

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (info[UIImagePickerControllerMediaURL]) [self.viewModel sendVideoMessage:info[UIImagePickerControllerMediaURL]];
    else [self.viewModel sendPictureMessage: info[UIImagePickerControllerEditedImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LMAudioMessageViewController Delegate

-(void) audioRecordingController:(LMAudioMessageViewController *)controller didFinishRecordingWithContents:(NSURL *)url
{
    [self.viewModel sendAudioMessage:url];
    [self cancelAudioRecorder:controller];
}

-(void) cancelAudioRecorder:(LMAudioMessageViewController *)controller
{
    [UIView animateWithDuration:0.5 animations:^{
        self.audioRecorder.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - JSQMessagesCollectionView Data Source

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self p_messageAtIndexPath:indexPath];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingMessageBubble;
    }
    
    return self.incomingMessageBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_avatarImages) {
        self.avatarImages = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.avatarImages objectForKey:senderId]) return [JSQMessagesAvatarImageFactory avatarImageWithImage:[self.avatarImages objectForKey:senderId] diameter:30.0f];
    
    if (!_placeholderAvatar) {
        self.placeholderAvatar = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"?" backgroundColor:[UIColor lightGrayColor] textColor:[UIColor whiteColor] font:[UIFont fontWithName:@"Noteworthy-Light" size:12] diameter:30.0f ];
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
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - TextField Delegate

-(void)textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    if (self.isTyping == false && textView.text.length > 0) {
        [[self.typingFirebase childByAppendingPath:self.senderDisplayName] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
        [self.inputToolbar.contentView setRightBarButtonItem:_sendButton];
        self.isTyping = true;
    } else if (self.isTyping == true && textView.text.length == 0) {
        [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        self.isTyping = false;
    }
}


#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.messages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messages))];
        self.avatarImages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarImages))];
        self.firebaseAddress = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebaseAddress))];
        self.groupId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(groupId))];
        self.titleView = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(titleView))];
        self.titleLabel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(titleLabel))];
        self.chatTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatTitle))];
        
    } else {
        return nil;
    }
    
    self.newMessageCount = 0;
    self.viewModel = [[LMChatViewModel alloc] initWithViewController:self];
    if (self.messages.count != 0) self.viewModel.initialized = YES;
    [self p_setupFirebase];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.messages forKey:NSStringFromSelector(@selector(messages))];
    [aCoder encodeObject:self.avatarImages forKey:NSStringFromSelector(@selector(avatarImages))];
    [aCoder encodeObject:self.firebaseAddress forKey:NSStringFromSelector(@selector(firebaseAddress))];
    [aCoder encodeObject:self.groupId forKey:NSStringFromSelector(@selector(groupId))];
    [aCoder encodeObject:self.titleView forKey:NSStringFromSelector(@selector(titleView))];
    [aCoder encodeObject:self.titleLabel forKey:NSStringFromSelector(@selector(titleLabel))];
    [aCoder encodeObject:self.chatTitle forKey:NSStringFromSelector(@selector(chatTitle))];
}


#pragma mark - Private Methods

-(void) p_setupFirebase
{
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
        }
        
        [self finishSendingMessageAnimated:YES];
    }
}

-(void) refreshTypingLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    [self.typingLabel setText:[self.viewModel updateTypingLabelWithSnapshot:snapshot]];
    if ([self.delegate respondsToSelector:@selector(peopleTypingText:)]) [self.delegate peopleTypingText:self.typingLabel.text];
}

-(void) refreshTitleLabelWithSnapshot:(FDataSnapshot *)snapshot
{
    [self.titleLabel setText:[self.viewModel updateTitleLabelWithSnapshot:snapshot]];
    if ([self.delegate respondsToSelector:@selector(numberOfPeopleOnline:changedForChat:)]) [self.delegate numberOfPeopleOnline:snapshot.childrenCount changedForChat:self.groupId];
}

-(JSQMessage *) p_messageAtIndexPath:(NSIndexPath *)indexPath
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

@end