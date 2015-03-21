#import "ChatView.h"
#import <JSQMessages.h>
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMMessages.h"

@interface ChatView ()

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoading;

@property (strong, nonatomic) NSString *groupId;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) LMMessages *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageIncoming;
@property (strong, nonatomic) JSQMessagesAvatarImage *avatarImageBlank;

@end

@implementation ChatView

-(instancetype) initWithGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        _groupId = groupId;
        self.messages = [[LMMessages alloc] initWithGroupID:groupId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Chat";

    self.users = [[NSMutableArray alloc] init];
    self.avatars = [[NSMutableDictionary alloc] init];
    
//    [[LMMessages sharedInstance] addObserver:self forKeyPath:@"messages" options:0 context:nil];
 
    PFUser *user = [PFUser currentUser];
    self.senderId = user.username;
    self.senderDisplayName = user[PF_USER_USERNAME];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    self.avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"sample-302-swords.png"] diameter:40];

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
    [self.messages checkForNewMessages];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *message = [self.messages messages][indexPath.item];
    
    JSQMessage *jsqMessage = [self createJSQMessageFromObject:message];
    
    return jsqMessage;
}

#pragma mark - Helper Method

-(JSQMessage *)createJSQMessageFromObject:(PFObject *)object
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:object[PF_MESSAGE_SENDER_NAME] senderDisplayName:object[PF_MESSAGE_SENDER_NAME] date:object.createdAt text:object[@"text"]];
    
    return message;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = [self createJSQMessageFromObject:[self.messages messages][indexPath.item]];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return self.bubbleImageOutgoing;
    }
    return self.bubbleImageIncoming;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    PFUser *object = [self.messages messages][indexPath.row][PF_MESSAGES_USER];
    PFUser *messageSender;
    
    for (PFUser *user in [self.messages chatMembers]) {
        if ([user.objectId isEqualToString:object.objectId]) {
            messageSender = user;
        }
    }
    
    if (!self.avatars[messageSender.objectId]) {
    
        PFFile *fileThumbnail = messageSender[PF_USER_THUMBNAIL];
        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (error == nil)
            {
                self.avatars[messageSender.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                [self.collectionView reloadData];
            }
        }];
    }
    
    return self.avatars[messageSender.objectId];
    
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
    
    [self.messages sendMessage:message withCompletion:^(NSError *error) {
        [self finishSendingMessageAnimated:YES];
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = [self createJSQMessageFromObject:[self.messages messages][indexPath.item]];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = [self createJSQMessageFromObject:[self.messages messages][indexPath.item]];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return nil;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = [self createJSQMessageFromObject:[self.messages messages][indexPath.item - 1]];
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
    return [self.messages messages].count;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self createJSQMessageFromObject:[self.messages messages][indexPath.item]];
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
    JSQMessage *message = [self createJSQMessageFromObject:[self.messages messages][indexPath.item]];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return 0;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = [self createJSQMessageFromObject:[self.messages messages][indexPath.item - 1]];
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

//-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (object == [LMMessages sharedInstance] && [keyPath isEqualToString:@"messages"]) {
//        // We know mediaItems changed.  Let's see what kind of change it is.
//        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
//        
//        if (kindOfChange == NSKeyValueChangeSetting) {
//            // Someone set a brand new images array
//            [self.collectionView reloadData];
//            
//        } else if (kindOfChange == NSKeyValueChangeInsertion ||
//                   kindOfChange == NSKeyValueChangeRemoval ||
//                   kindOfChange == NSKeyValueChangeReplacement) {
//            
//            [self.collectionView reloadData];
//        }
//    }
//}


@end
