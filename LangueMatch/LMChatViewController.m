#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "NSDate+Chats.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMUserProfileViewController.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface LMChatViewController () <NSCoding>

@property (strong, readwrite, nonatomic) NSString *firebaseAddress;
@property (strong, readwrite, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSMutableOrderedSet *messages;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *typingLabel;

@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) BOOL initialized;
@property (assign, nonatomic) NSUInteger numberOfMessagesToShow;

@property (strong, nonatomic) Firebase *messageFirebase;
@property (strong, nonatomic) Firebase *typingFirebase;
@property (strong, nonatomic) Firebase *memberFirebase;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImageFactory *bubbleFactory;
@property (strong, nonatomic) JSQMessagesAvatarImage *placeholderAvatar;

@property (strong, nonatomic) NSMutableDictionary *avatarImages;

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
    
    self.senderDisplayName = [PFUser currentUser].username;
    self.senderId = [PFUser currentUser].objectId;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    
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

#pragma mark - JSQMessagesViewController Delegate

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self p_sendMessage:text withMedia:nil];
    [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
    self.isTyping = false;
}

-(void) didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
}

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

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [self p_sendMessage:nil withMedia:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        self.isTyping = true;
    } else if (self.isTyping == true && textView.text.length == 0) {
        [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
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
    
    if (self.messages.count != 0) self.initialized = YES;
    self.newMessageCount = 0;
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
    self.messageFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/messages", _firebaseAddress, _groupId]];
    self.typingFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/typing", _firebaseAddress, _groupId]];
    self.memberFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/members", _firebaseAddress, _groupId]];
    
    [self.typingFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self p_updateTypingLabel:snapshot];
    }];
    
    [self.memberFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self p_updateTitleLabel:snapshot];
    }];
    
    [self.messageFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self p_addMessage:snapshot.value];
    }];
    
    if (!_initialized) {
        [self.messageFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            [self finishReceivingMessage];
            [self scrollToBottomAnimated:NO];
            self.automaticallyScrollsToMostRecentMessage = YES;
            _initialized = YES;
        }];
    }
}

-(void) p_addMessage:(NSDictionary *)message
{
    NSUInteger currentMessageCount = self.messages.count;
    NSDate *date = [NSDate lm_stringToDate:message[@"date"]];
    
    JSQMessage *jsqMessage;
    JSQMessage *lastMessage = [self.messages lastObject];
    
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
                    
                    mediaItem.image = (UIImage *)responseObject;
                    [self.collectionView reloadData];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed retreiving message");
                }];
                
                [[NSOperationQueue mainQueue] addOperation:operation];
            }
        }
        
        [self.messages addObject:jsqMessage];
        if ([self.delegate respondsToSelector:@selector(lastMessage:forChat:)]) [self.delegate lastMessage:message forChat:self.groupId];
        self.newMessageCount++;
        if ([self.delegate respondsToSelector:@selector(incrementedNewMessageCount:ForChat:)]) [self.delegate incrementedNewMessageCount:self.newMessageCount ForChat:self.groupId];
        
        if ([senderId isEqualToString:self.senderId]) {
            [self finishSendingMessageAnimated:YES];
            
        } else {
            NSUInteger newMessagecount = self.messages.count - currentMessageCount;
            if (newMessagecount) {
                //Can use to archive message and update new message count in UI
            }
            
            if ([jsqMessage isMediaMessage]) {
                JSQMediaItem *mediaItem = (JSQMediaItem *)jsqMessage.media;
                mediaItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            
            [self finishReceivingMessageAnimated:YES];
        }
    }
}


-(void) p_updateTypingLabel:(FDataSnapshot *)change
{
    NSUInteger childrenCount = change.childrenCount;
    NSMutableArray *children;
    
    if (childrenCount) {
        children = [[NSMutableArray alloc] init];
        for (FDataSnapshot *child in change.children) {
            if (![[child key] isEqualToString:self.senderDisplayName]) {
                [children addObject:[child key]];
            }
        }
    }
    
    if (children.count > 1) {
        [self.typingLabel setText:@"2 or more people are typing..."];
    } else if (children.count == 1){
        [self.typingLabel setText:[NSString stringWithFormat:@"%@ is typing...", children[0]]];
    } else {
        [self.typingLabel setText:[NSString stringWithFormat:@"%lu people online", _peopleOnline]];
    }
    
    if ([self.delegate respondsToSelector:@selector(peopleTypingText:)]) [self.delegate peopleTypingText:self.typingLabel.text];

}

-(void) p_updateTitleLabel:(FDataSnapshot *)change
{
    NSUInteger childrenCount = change.childrenCount;
    self.peopleOnline = childrenCount;
    
    if (childrenCount == 1) {
        [self.titleLabel setText:[NSString stringWithFormat:@"%@", _chatTitle]];
    } else if (childrenCount == 2) {
        for (FDataSnapshot *child in change.children) {
            if (![child.key isEqualToString:[PFUser currentUser].username]) {
                [self.typingLabel setText:[NSString stringWithFormat:@"%@ is online", child.key]];
                return;
            }
        }
    } else if (childrenCount > 2) {
        [self.typingLabel setText:[NSString stringWithFormat:@"%lu people online", (unsigned long)childrenCount]];
    }
    
    if ([self.delegate respondsToSelector:@selector(numberOfPeopleOnline:changedForChat:)]) [self.delegate numberOfPeopleOnline:childrenCount changedForChat:self.groupId];
}

-(JSQMessage *) p_messageAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger path = indexPath.item;
    NSUInteger items = self.messages.count;
    
    if (self.numberOfMessagesToShow > self.messages.count)
        return self.messages[path];
    
    return self.messages[(items - self.numberOfMessagesToShow) + path];
}

-(void) p_sendMessage:(NSString *)text withMedia:(id)media
{
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"senderId"] = self.senderId;
    message[@"senderDisplayName"] = self.senderDisplayName;
    message[@"date"] = dateString;
    
    
    if (text) {
        message[@"type"] = @"text";
        message[@"text"] = text;
        
        [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error != nil) {
                NSLog(@"Error Sending Message - Check network");
            }
        }];
        
    } else if (media) {
        PFFile *file;
        
        if ([media isKindOfClass:[UIImage class]]) {
            file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(media, 0.9)];
            
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error == nil) {
                    message[@"picture"] = file.url;
                    message[@"text"] = @"Picture Message";
                    message[@"type"] = @"picture";
                    
                    [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                        if (error != nil) {
                            NSLog(@"Error Sending Message - Check network");
                        }
                    }];
                }
            }];
        }
    }
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