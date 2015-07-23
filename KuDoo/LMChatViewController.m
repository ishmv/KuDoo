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

typedef void (^LMPhotoIndexFinder)(NSInteger index);

@interface LMChatViewController () <LMAudioMessageViewControllerDelegate>

// UI properties
@property (strong, nonatomic) NSMutableOrderedSet *messages;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *onlineLabel;
@property (nonatomic, assign, readwrite) NSInteger peopleOnline;
@property (nonatomic, assign, readwrite) NSInteger newMessageCount;
@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) NSUInteger numberOfMessagesToShow;
@property (strong, nonatomic, readwrite) NSMutableDictionary *avatarImages;
@property (strong, nonatomic) LMChatViewModel *viewModel;

// Firebase locations
@property (strong, nonatomic) Firebase *messageFirebase;
@property (strong, nonatomic) Firebase *typingFirebase;
@property (strong, nonatomic) Firebase *memberFirebase;

// For attaching media mesages
@property (strong, nonatomic) LMAudioMessageViewController *audioRecorder;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *attachButton;

// Storing and displaying photos in chat window
@property (strong, nonatomic) IDMPhotoBrowser *photoBrowser;
@property (strong, nonatomic, readwrite) NSMutableArray *photosArray;
@property (strong, nonatomic, readwrite) NSMutableOrderedSet *photoMapper;

@end

@implementation LMChatViewController

static NSUInteger const messageCountPerSection = 10;

#pragma mark - View Controller Life Cycle

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId {
    if (self = [super init]) {
        _firebaseAddress = address;
        _groupId = groupId;
        _newMessageCount = 0;
        _viewModel = [[LMChatViewModel alloc] initWithViewController:self];
        _numberOfMessagesToQuery = 10;
        [self p_setupFirebase];
    }
    return self;
}

-(instancetype) init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithFirebaseAddress:andGroupId:" userInfo:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_messages) {
        self.messages = [[NSMutableOrderedSet alloc] init];
    }
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        [label setFont:[UIFont lm_robotoLightLarge]];
        label.text = NSLocalizedString(@"Chat", @"chat");
        label;
    });
    
    self.typingLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        [label setFont:[UIFont lm_robotoLightTimestamp]];
        label;
    });
    
    self.titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    self.onlineLabel = [[UILabel alloc] init];
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont lm_robotoLightMessage];
    
    //Need to change JSQMessagesInputToolbar.m toggleSendButtonEnabled to always return YES
    UIImage *microphone = ({
        UIImage *image = [UIImage imageNamed:@"microphone.png"];
        image;
    });
    
    self.microphoneButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:microphone forState:UIControlStateNormal];
        button.backgroundColor = [UIColor lm_cloudsColor];
        [button.layer setCornerRadius:10.0f];
        [button.layer setMasksToBounds:YES];
        button;
    });
    
    //JSQMessagesViewController property settings
    [self.inputToolbar.contentView setRightBarButtonItem:self.microphoneButton];
    self.sendButton = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    self.attachButton = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    [self.inputToolbar.contentView setLeftBarButtonItem:self.attachButton];
    self.senderDisplayName = [PFUser currentUser][PF_USER_DISPLAYNAME];
    self.senderId = [PFUser currentUser].objectId;
    self.showLoadEarlierMessagesHeader = YES;
    self.numberOfMessagesToShow = 10;
    self.inputToolbar.contentView.textView.font = [UIFont lm_robotoLightMessage];
    
    for (UILabel *label in @[self.titleLabel, self.typingLabel]) {
        [self.titleView addSubview:label];
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.navigationItem setTitleView:self.titleView];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.memberFirebase childByAppendingPath:self.senderId] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
    
    [self.typingFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self refreshTypingLabelWithSnapshot:snapshot];
    }];
    
    [self.memberFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self refreshMemberLabelWithSnapshot:snapshot];
    }];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self p_resetNewMessageCount];
}

-(void) viewWillDisappear:(BOOL)animated {
    [self p_resetNewMessageCount];
    [self.memberFirebase updateChildValues:@{self.senderId: @{}}];
    [super viewWillDisappear:animated];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat titleLabelOffset = 10.0f;
    
    CENTER_VIEW_H(self.titleView, _titleLabel);
    CENTER_VIEW_H(self.titleView, _typingLabel);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.titleView, _titleLabel, titleLabelOffset);
    ALIGN_VIEW_TOP_CONSTANT(self.titleView, _typingLabel, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    [self.memberFirebase removeAllObservers];
    [self.typingFirebase removeAllObservers];
    [self.messageFirebase removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - JSQMessagesInputToolbar Delegate

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    UIAlertController *chooseSourceTypeAlert = [LMAlertControllers chooseCameraSourceAlertWithCompletion:^(NSInteger type) {
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

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    if (sender == _microphoneButton) {
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
    } else {
        [self.viewModel saveTextMessage:toolbar.contentView.textView.text toFirebase:self.messageFirebase];
        AudioServicesPlaySystemSound(1004);
        [self.inputToolbar.contentView setRightBarButtonItem:_microphoneButton];
        [self.typingFirebase updateChildValues:@{self.senderId : @{}}];
        self.isTyping = false;
    }
}

#pragma mark - JSQMessagesViewController Delegate

-(void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSInteger difference = self.messages.count - self.numberOfMessagesToShow;
    
    if (difference > messageCountPerSection) {
        self.numberOfMessagesToShow += messageCountPerSection;
    } else {
        self.numberOfMessagesToShow += difference;
    }
    
    [self.collectionView reloadData];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[JSQPhotoMediaItem class]])
        {
            [self p_photoIndexForDate:message.date withCompletion:^(NSInteger index) {
                self.photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:self.photosArray];
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (info[UIImagePickerControllerMediaURL]) [self sendVideoMessageWithURL:info[UIImagePickerControllerMediaURL]];
    else [self sendPictureMessageWithImage:info[UIImagePickerControllerEditedImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LMAudioMessageViewController Delegate

-(void) audioRecordingController:(LMAudioMessageViewController *)controller didFinishRecordingWithContents:(NSURL *)url {
    [self sendAudioMessageWithUrl:url];
    [self cancelAudioRecorder:controller];
}

-(void) cancelAudioRecorder:(LMAudioMessageViewController *)controller {
    [UIView animateWithDuration:0.5f animations:^{
        self.audioRecorder.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - JSQMessagesCollectionView Data Source

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self messageAtIndexPath:indexPath];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.viewModel.outgoingMessageBubble;
    }
    
    return self.viewModel.incomingMessageBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_avatarImages) {
        self.avatarImages = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.avatarImages objectForKey:senderId]) return [JSQMessagesAvatarImageFactory avatarImageWithImage:[self.avatarImages objectForKey:senderId] diameter:45.0f];
    
    if (!_viewModel.placeholderAvatar) {
        self.viewModel.placeholderAvatar = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"?" backgroundColor:[UIColor lightGrayColor] textColor:[UIColor whiteColor] font:[UIFont lm_robotoLightMessage] diameter:45.0f];
    }
    
    PFUser *user = [PFUser objectWithoutDataWithObjectId:senderId];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedUser, NSError *error) {
        PFFile *thumbnailFile = [fetchedUser objectForKey:PF_USER_THUMBNAIL];
        [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [self.avatarImages setValue:image forKey:senderId];
                [self.collectionView reloadData];
            });

        }];
    }];
    
    return self.viewModel.placeholderAvatar;
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 15;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *dateString = [NSString lm_dateToStringShortTimeOnly:message.date];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor lm_wetAsphaltColor]};
    
    return [[NSAttributedString alloc] initWithString:dateString attributes:attributes];
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = [self messageAtIndexPath:indexPath];
    JSQMessage *previousMessage = nil;
    
    if (indexPath.item > 0) {
        NSIndexPath *previous = [NSIndexPath indexPathForItem:(indexPath.item - 1) inSection:indexPath.section];
        previousMessage = ([self messageAtIndexPath:previous]) ?: nil;
    }
    
    return [self.viewModel attributedStringForCellTopLabelFromMessage:currentMessage withPreviousMessage:previousMessage forIndexPath:indexPath];
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if ([self collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath]) {
        return 30;
    }
    
    return 0;
}


#pragma mark - UICollectionView Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.messages.count < self.numberOfMessagesToShow) {
        return self.messages.count;
    }
    
    return self.numberOfMessagesToShow;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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

-(void)textViewDidChange:(UITextView *)textView {
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

#pragma mark - Message Create

-(void) createMessageWithInfo:(NSDictionary *)message {
    JSQMessage *jsqMessage = [self.viewModel createMessageWithInfo:message];
    
    if (jsqMessage != nil) {
        
        [self.messages addObject:jsqMessage];
        if ([self.delegate respondsToSelector:@selector(updateLastMessage:forChatViewController:)]) [self.delegate updateLastMessage:message forChatViewController:self];
        
        self.newMessageCount++;
        if ([self.delegate respondsToSelector:@selector(incrementNewMessageCount:forChatViewController:)]) [self.delegate incrementNewMessageCount:_newMessageCount forChatViewController:self];
        
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

#pragma mark - UI Updates

-(void) refreshTypingLabelWithSnapshot:(FDataSnapshot *)snapshot {
    NSString *typingText = [self.viewModel updateTypingLabelWithSnapshot:snapshot];
    if ([typingText isEqualToString:@""]) [self.typingLabel setText:_onlineLabel.text];
    else [self.typingLabel setText:typingText];
    [self p_updateTitlePosition];
}

-(void) refreshMemberLabelWithSnapshot:(FDataSnapshot *)snapshot {
    NSUInteger childrenCount = snapshot.childrenCount;
    self.peopleOnline = childrenCount;
    
    NSString *onlineText = [self.viewModel updateMemberLabelWithSnapshot:snapshot];
    [self.onlineLabel setText:onlineText];
    if ([self.typingLabel.text isEqualToString:@""]) [self.typingLabel setText:onlineText];
    if ([onlineText isEqualToString:@""]) [self.typingLabel setText:@""];
    else if ([self.delegate respondsToSelector:@selector(numberOfPeopleOnlineChanged:forChatViewController:)]) [self.delegate numberOfPeopleOnlineChanged:snapshot.childrenCount forChatViewController:self];
    [self p_updateTitlePosition];
}

#pragma mark - Setter Overrides
-(void) setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.collectionView.backgroundColor = backgroundColor;
}

-(void) setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [backgroundView setImage:backgroundImage];
    self.collectionView.backgroundView = backgroundView;
}

#pragma mark - Getter Overrides
-(NSOrderedSet *) allMessages {
    return [self.messages copy];
}

#pragma mark - Public Methods

-(void) storeImage:(UIImage *)image forDate:(NSDate *)date {
    if (!_photosArray) {
        self.photosArray = [[NSMutableArray alloc] init];
    }
    IDMPhoto *photo = [IDMPhoto photoWithImage:(UIImage *)image];
    [self.photosArray addObject:photo];
    
    if (!_photoMapper) {
        self.photoMapper = [[NSMutableOrderedSet alloc] init];
    }
    [self.photoMapper addObject:date];
}

-(void) sendAudioMessageWithUrl:(NSURL *)url {
    [self.viewModel saveAudioMessage:url toFirebase:self.messageFirebase];
}

-(void) sendPictureMessageWithImage:(UIImage *)image {
    [self.viewModel savePictureMessage:image toFirebase:self.messageFirebase];
}

-(void) sendVideoMessageWithURL:(NSURL *)url {
    [self.viewModel saveVideoMessage:url toFirebase:self.messageFirebase];
}

-(JSQMessage *) messageAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger path = indexPath.item;
    NSUInteger items = self.messages.count;
    
    if (self.numberOfMessagesToShow > self.messages.count)
        return self.messages[path];
    
    return self.messages[(items - self.numberOfMessagesToShow) + path];
}

#pragma mark - Private Methods

-(void) p_photoIndexForDate:(NSDate *)date withCompletion:(LMPhotoIndexFinder)completion {
    [self.photoMapper enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *storeDate = (NSDate *)obj;
        
        NSComparisonResult result = [storeDate compare:date];
        
        if (result == NSOrderedSame) {
            completion(idx);
            *stop = YES;
        }
    }];
}

-(void) p_setupFirebase {
    [self p_registerForApplicationStateNotifications];
    
    self.messageFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/messages", _firebaseAddress, _groupId]];
    self.typingFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/typing", _firebaseAddress, _groupId]];
    self.memberFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/chats/%@/members", _firebaseAddress, _groupId]];
    
    [self.typingFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self refreshTypingLabelWithSnapshot:snapshot];
    }];
    
    [self.memberFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self refreshMemberLabelWithSnapshot:snapshot];
    }];
    
    [[self.messageFirebase queryLimitedToLast:_numberOfMessagesToQuery] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self createMessageWithInfo:snapshot.value];
        [self scrollToBottomAnimated:NO];
    }];
}

-(void) p_updateTitlePosition {
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

-(void) p_resetNewMessageCount {
    self.newMessageCount = 0;
    if ([self.delegate respondsToSelector:@selector(incrementNewMessageCount:forChatViewController:)]) [self.delegate incrementNewMessageCount:_newMessageCount forChatViewController:self];
}

#pragma mark - Notifications

-(void) p_registerForApplicationStateNotifications {
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

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
   
    if (self = [super init]) {
        self.messages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messages))];
        self.avatarImages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarImages))];
        self.photosArray = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(photosArray))];
        self.photoMapper = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(photoMapper))];
        _firebaseAddress = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebaseAddress))];
        _groupId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(groupId))];

    } else {
        return nil;
    }
    
    _newMessageCount = 0;
    _numberOfMessagesToQuery = 10;
    _viewModel = [[LMChatViewModel alloc] initWithViewController:self];
    
    if (self.messages.count != 0) self.viewModel.initialized = YES;
    [self p_setupFirebase];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.messages forKey:NSStringFromSelector(@selector(messages))];
    [aCoder encodeObject:self.avatarImages forKey:NSStringFromSelector(@selector(avatarImages))];
    [aCoder encodeObject:self.firebaseAddress forKey:NSStringFromSelector(@selector(firebaseAddress))];
    [aCoder encodeObject:self.groupId forKey:NSStringFromSelector(@selector(groupId))];
    [aCoder encodeObject:self.photosArray forKey:NSStringFromSelector(@selector(photosArray))];
    [aCoder encodeObject:self.photoMapper forKey:NSStringFromSelector(@selector(photoMapper))];
}


@end