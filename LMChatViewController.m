//
//  LMChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatViewController.h"
#import "LMMessageModel.h"
#import "LMMessages.h"
#import "LMAlertControllers.h"
#import "AppConstant.h"

#import <Parse/Parse.h>
#import <JSQMessages.h>
#import <JSQMediaItem.h>

@interface LMChatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) LMMessageModel *messageModel;

@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (strong, nonatomic) JSQMessagesBubbleImage *bubbleImageIncoming;

@end

@implementation LMChatViewController

-(instancetype) initWithChat:(PFObject *)chat
{
    if (self = [super init]) {
        _chat = chat;
        
        _messageModel = [[LMMessageModel alloc] initWithChat:chat];
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
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    [self.messageModel addObserver:self forKeyPath:@"chatMessages" options:0 context:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkForNewMessages) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    JSQMessage *message =[self messageList][indexPath.item];
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

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"Stop");
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Stop");
}

#pragma mark - Target Action Methods

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
 
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    PFObject *message = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    PFUser *currentUser = [PFUser currentUser];
    
    message[PF_MESSAGE_USER] = currentUser;
    message[PF_MESSAGE_TEXT] = text;
    message[PF_MESSAGE_SENDER_NAME] = self.senderDisplayName;
    message[PF_MESSAGE_GROUPID] = _chat[PF_CHAT_GROUPID];
    message[PF_MESSAGE_SENDER_ID] = self.senderId;
    
    [LMMessages saveMessage:message toGroupId:_chat[PF_CHAT_GROUPID] withCompletion:^(PFObject *savedMessage, NSError *error) {
        if (!error)
        {
            [self.messageModel addChatMessagesObject:savedMessage];
            [self finishSendingMessageAnimated:YES];
        }
        else
        {
            NSLog(@"%@", error);
        }
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

-(void)checkForNewMessages
{
    [LMMessages checkNewMessagesForChat:_chat withCompletion:^(NSArray *messages) {
        if (messages) {
            for (PFObject *message in messages) {
                [self.messageModel addChatMessagesObject:message];
                [self finishReceivingMessageAnimated:YES];
            }
        }
    }];
}

#pragma mark - Helper Methods

-(NSArray *) messageList
{
    return [self.messageModel chatMessages];
}


#pragma mark - UIImagePickerSource Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //ToDo
}


@end
