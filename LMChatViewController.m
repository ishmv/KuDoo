//
//  LMChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatViewController.h"
#import "LMMessages.h"
#import "LMAlertControllers.h"
#import "AppConstant.h"
#import "LMData.h"
#import "LMParseConnection.h"

#import <Parse/Parse.h>
#import <JSQMessages.h>
#import <JSQMediaItem.h>

@interface LMChatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *JSQmessages;
@property (strong, nonatomic) NSMutableArray *LMMessages;

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageIncoming;

@property (strong, nonatomic) UIImage *chatImage;

@end

@implementation LMChatViewController

-(instancetype) initWithChat:(PFObject *)chat
{
    if (self = [super init]) {
        _chat = chat;
        
        // Need cache mechanism in between application launches
        [self p_getChatImage];
        [self p_getChatMessages];
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    _bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.senderDisplayName = [PFUser currentUser].username;
    self.senderId = [PFUser currentUser].objectId;
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<Chats" style:UIBarButtonItemStylePlain target:self action:@selector(userPressedBackButton:)];
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
    return [self messageList][indexPath.item];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageList][indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.bubbleImageOutgoing;
    }
    
    return self.bubbleImageIncoming;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self messageList].count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self messageList][indexPath.item];
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

#pragma mark - JSQMessagesCollectionViewDelegateFlowLayout



#pragma mark - Target Action Methods

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    
    if (!_JSQmessages)
    {
        self.JSQmessages = [NSMutableArray array];
    }
    
    [self.JSQmessages addObject:jsqMessage];
    
    PFObject *message = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    PFUser *currentUser = [PFUser currentUser];
    message[PF_MESSAGE_USER] = currentUser;
    message[PF_MESSAGE_TEXT] = text;
    message[PF_MESSAGE_SENDER_NAME] = self.senderDisplayName;
    message[PF_MESSAGE_GROUPID] = self.chat[PF_CHAT_GROUPID];
    message[PF_MESSAGE_SENDER_ID] = self.senderId;
    [message setObject:self.chat forKey:PF_CHAT_CLASS_NAME];
    
    [LMParseConnection saveMessage:message withCompletion:^(BOOL succeeded, NSError *error)
    {
        [self finishSendingMessageAnimated:YES];
    }];
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    UIAlertController *chooseSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger type) {
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            imagePickerVC.allowsEditing = YES;
            imagePickerVC.delegate = self;
            imagePickerVC.sourceType = type;
            [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:chooseSourceTypeAlert animated:YES completion:nil];
}

#pragma mark - Helper Methods

-(NSArray *) messageList
{
    return _JSQmessages;
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
                chatImageView.frame = CGRectMake(0, 0, 40, 40);
                
                UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:20 startAngle:0 endAngle:2*M_PI clockwise:YES];
                CAShapeLayer *mask = [CAShapeLayer layer];
                mask.path = clippingPath.CGPath;
                chatImageView.layer.mask = mask;
                
                UIBarButtonItem *chatImageButton = [[UIBarButtonItem alloc] initWithCustomView:chatImageView];
                
                //After testing replace with full screen image viewer
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receiveMessage:)];
                tapGesture.delegate = self;
                chatImageView.userInteractionEnabled = YES;
                [chatImageView addGestureRecognizer:tapGesture];
                
                [self.navigationItem setRightBarButtonItem:chatImageButton];
            });
        }];
    }
}

-(void)p_getChatMessages
{
    if (!_LMMessages && self.chat.objectId)
    {
        [LMParseConnection getMessagesForChat:self.chat withCompletion:^(NSArray *messages, NSError *error) {
            self.LMMessages = [NSMutableArray arrayWithArray:messages];
            
            for (PFObject *LMMessage in self.LMMessages) {
                [self p_createJSQMessageFromLMMessage:LMMessage];
                [self.collectionView reloadData];
            }
        }];
    }
}

-(void) p_createJSQMessageFromLMMessage:(PFObject *)message
{
    if (!_JSQmessages) {
        _JSQmessages = [NSMutableArray array];
    }
    
    //    if (message[PF_MESSAGE_IMAGE])
    //    {
    //
    //    } else {
    
    JSQMessage *lastMessage = [_JSQmessages lastObject];
    if (![lastMessage.date isEqualToDate:message.updatedAt]) {
        JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:message[PF_MESSAGE_SENDER_ID] senderDisplayName:message[PF_MESSAGE_SENDER_NAME] date:message.updatedAt text:message[PF_MESSAGE_TEXT]];
        [_JSQmessages addObject:jsqMessage];
    }
    
    //    }
}

#pragma mark - UIImagePickerSource Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //ToDo
}

#pragma mark - Delegate Methods

-(void) userPressedBackButton:(UIBarButtonItem *)sender
{
    [self.inputToolbar endEditing:YES];
    [self.delegate userEndedChat:_chat];
    [self.navigationController popViewControllerAnimated:YES];
}

/*  
 
 
 These Methods are used for local testing - delete once backend is running
 
 */

#pragma mark - Receiving Messages

-(void) receiveMessage:(UIGestureRecognizer *)gesture
{
    PFObject *newMessage = [[LMData sharedInstance] receiveMessage];
    
    if (!_JSQmessages) {
        _JSQmessages = [NSMutableArray array];
    }
    
    if (newMessage[PF_MESSAGE_IMAGE]) {
        
        PFFile *imageFile = newMessage[PF_MESSAGE_IMAGE];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            UIImage *image = [UIImage imageWithData:data];
            JSQPhotoMediaItem *photoMedia = [[JSQPhotoMediaItem alloc] initWithImage:image];
            
            JSQMessage *mediaMessage = [[JSQMessage alloc] initWithSenderId:newMessage[PF_MESSAGE_SENDER_ID] senderDisplayName:newMessage[PF_MESSAGE_SENDER_NAME] date:newMessage[PF_MESSAGE_TIMESENT] media:photoMedia];
            [_JSQmessages addObject:mediaMessage];
            [self finishReceivingMessageAnimated:YES];
        }];
        
    } else {
        
        JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:newMessage[PF_MESSAGE_SENDER_ID] senderDisplayName:newMessage[PF_MESSAGE_SENDER_NAME] date:newMessage[PF_MESSAGE_TIMESENT] text:newMessage[PF_MESSAGE_TEXT]];
        [self.JSQmessages addObject:jsqMessage];
        [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
        [self finishReceivingMessageAnimated:YES];
        
    }
}

#pragma mark - Remote Notification

-(void) receivedNewMessage:(PFObject *)message
{
    [self p_createJSQMessageFromLMMessage:message];
    [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    [self finishReceivingMessageAnimated:YES];
}

@end
