#import "ChatView.h"
#import "AppConstant.h"
#import "LMMessages.h"
#import "LMData.h"

#import <JSQMessages.h>
#import <Parse/Parse.h>

@interface ChatView ()

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoading;

@property (strong, nonatomic) NSString *groupId;

@property (strong, nonatomic) NSMutableArray *chatMembers;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) PFObject *chat;

@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageIncoming;
@property (strong, nonatomic) JSQMessagesAvatarImage *avatarImageBlank;

@property (assign, nonatomic) BOOL isRandomChat;

@end

@implementation ChatView

-(instancetype) initWithChat:(PFObject *)chat
{
    if (self = [super init]) {
        
        _chat = chat;
        
        _isRandomChat = (chat[PF_CHAT_RANDOM]) ? YES : NO;
        
        [[LMMessages sharedInstance] setChat:chat];
        
        _groupId = chat[PF_CHAT_GROUPID];
        _chatMembers = [[NSMutableArray alloc] initWithArray:chat[PF_CHAT_MEMBERS]];
        
        if ([self sharedMessages] != 0) {
            for (PFObject *message in [self sharedMessages]) {
                [self createJSQMessageFromObject:message];
            }
        } else {
            // New Chat
            NSLog(@"New Chat Started");
        }
    }
    return self;
}

-(void) loadChatImages
{
    
}

#pragma mark - View Controller Life Cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _chat[PF_CHAT_TITLE];
    
    if (_isRandomChat)
    {
        [self setupUIForRandomChat];
    }
    
    self.avatars = [[NSMutableDictionary alloc] init];
 
    PFUser *user = [PFUser currentUser];
    self.senderId = user.username;
    self.senderDisplayName = user[PF_USER_USERNAME];
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    self.avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"empty_profile.png"] diameter:40];

    self.isLoading = NO;

//    ClearMessageCounter(groupId);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadMessages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
}

-(void) loadMessages
{
    [[LMMessages sharedInstance] checkForNewMessagesWithCompletion:^(int newMessageCount) {
        if (newMessageCount) {
            for (int i = (int)[self.messages count]; i < (int)[self sharedMessages].count; i++) {
                [self createJSQMessageFromObject:[self sharedMessages][i]];
            }
            
        }
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:YES];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSArray *) sharedMessages
{
    return [[LMMessages sharedInstance] messages];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    PFObject *message = self.messages[indexPath.item];
//    
//    JSQMessage *jsqMessage = [self createJSQMessageFromObject:message];
    
    return self.messages[indexPath.item];
}


#pragma mark - Helper Method

-(void)createJSQMessageFromObject:(PFObject *)object
{
    if (!self.messages) {
        self.messages = [[NSMutableArray alloc] init];
    }
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:object[PF_MESSAGE_SENDER_NAME] senderDisplayName:object[PF_MESSAGE_SENDER_NAME] date:object.createdAt text:object[@"text"]];
    
    [self.messages addObject:message];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return self.bubbleImageOutgoing;
    }
    return self.bubbleImageIncoming;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = self.messages[indexPath.row];
    
    NSString *senderName = message.senderDisplayName;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *otherUser;
    
    for (PFUser *user in self.chatMembers) {
        if (![user.username isEqualToString:currentUser.username]) {
            otherUser = user;
        }
    }
    
    PFUser *messageSender = ([currentUser.username isEqualToString:senderName]) ? currentUser : otherUser;
    
    
    if (!self.avatars[messageSender.objectId]) {
        
        PFFile *fileThumbnail = messageSender[PF_USER_THUMBNAIL];
        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 self.avatars[messageSender.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                 [self.collectionView reloadData];
             }
         }];
        
        return self.avatarImageBlank;
    }
    else return self.avatars[messageSender.objectId];
}


-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
    
    PFUser *user = [PFUser currentUser];
    
    message[PF_MESSAGES_USER] = user;
    message[PF_CHAT_TEXT] = text;
    message[PF_MESSAGE_SENDER_NAME] = user.username;
    message[PF_MESSAGES_GROUPID] = self.groupId;
    message[PF_MESSAGE_SENDER_ID] = user.objectId;
    
    [[LMMessages sharedInstance] sendMessage:message withCompletion:^(NSError *error) {
        
        if (!error) {
            [self createJSQMessageFromObject:message];
            [[LMData sharedInstance] updateChatList];
            [self finishSendingMessageAnimated:YES];
        } else {
            NSLog(@"Error Sending Message");
        }
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = self.messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return nil;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item - 1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return self.messages.count;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message =self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return 0;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item - 1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return 0;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 0;
}

#pragma mark - Random Chat Methods

-(void) setupUIForRandomChat
{
//    PFUser *currentUser = [PFUser currentUser];
//    PFUser *otherUser;
//    
//    for (PFUser *user in self.chatMembers) {
//        if (![user.username isEqualToString:currentUser.username]) {
//            otherUser = user;
//        }
//    }
//    
////    UIImageView *pictureImage = (_randomPersonPicture) ? _randomPersonPicture : [[UIImageView alloc]initWithImage:[UIImage  imageNamed:@"empty_profile.png"]];
//    
//    UIBarButtonItem *leaveChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActionList:)];
//    [self.navigationController.topViewController.navigationItem setLeftBarButtonItem:leaveChatButton];
//    
//    pictureImage.contentMode = UIViewContentModeScaleAspectFill;
//    pictureImage.frame = CGRectMake(0, 0, 40, 40);
//    UIBarButtonItem *profilePictureButton = [[UIBarButtonItem alloc] initWithCustomView:pictureImage];
//    
//    [self.navigationController.topViewController.navigationItem setRightBarButtonItem:profilePictureButton];
//    
//    self.title = _chat[PF_CHAT_TITLE];
}

-(void)presentActionList:(UIButton *)button
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"What would you like to do?", @"What would you like to do?")
                                                                       message:NSLocalizedString(@"The chat is not recoverable to maintain user privacy", @"The chat is not recoverable to maintian user privacy")
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *reportUser = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report User - Unresponive", @"Report User - Unresponsive")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        //Todo - give user bad rating
    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                            style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *addFriendAction = [UIAlertAction actionWithTitle:@"Send Friend Request"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
        // Todo - "a friend request will be sent to user"
    }];
    
    UIAlertAction *leaveChatAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Leave Chat", @"Leave Chat")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                            }];
    
    for (UIAlertAction *action in @[defaultAction, reportUser, addFriendAction, leaveChatAction]) {
        [alertView addAction:action];
    }
    
    [self presentViewController:alertView animated:YES completion:nil];
//    [self.delegate endedRandom:_chat];
}


@end
