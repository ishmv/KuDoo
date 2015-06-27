//
//  LMPrivateChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMPrivateChatViewController.h"
#import "AppConstant.h"
#import "PushNotifications.h"
#import "LMUserProfileViewController.h"
#import "ParseConnection.h"
#import "NSString+Chats.h"
#import "LMChatDetails.h"

#import <Firebase/Firebase.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface LMPrivateChatViewController ()

@property (strong, nonatomic) NSDictionary *chatInfo;
@property (copy, nonatomic) NSString *baseAddress;
@property (strong, nonatomic) NSDictionary *profileVCs;

@end

@implementation LMPrivateChatViewController

#pragma mark - View Controller LifeCycle

-(instancetype) initWithFirebaseAddress:(NSString *)address andChatInfo:(NSDictionary *)info
{
    if (self = [super initWithFirebaseAddress:address andGroupId:info[@"groupId"]]) {
        if (info != nil) {
            _baseAddress = address;
            _chatInfo = info;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_setNewMessageCount];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self p_setNewMessageCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.profileVCs = nil;
}

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [super messagesInputToolbar:toolbar didPressRightBarButton:sender];
    
    if (sender == self.sendButton) {
        [self p_sendMessageNotifications];
    }
}

#pragma mark - JSQMessagesCollectionView Delegate

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_profileVCs) {
        self.profileVCs = [[NSMutableDictionary alloc] init];
    }
    
    __block LMUserProfileViewController *userVC = self.profileVCs[senderId];
    
    if (userVC == nil) {
        [ParseConnection searchForUserIds:@[senderId] withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            PFUser *user = [objects firstObject];
            userVC = [[LMUserProfileViewController alloc] initWithUser:user];
            [self.profileVCs setValue:userVC forKey:senderId];
            [self presentViewController:userVC animated:YES completion:nil];
        }];
    } else {
        [self presentViewController:userVC animated:YES completion:nil];
    }
}

#pragma mark - Private Methods

-(void) p_updateFirebaseInformation
{
    NSString *groupId = _chatInfo[@"groupId"];
    NSString *chatType = _chatInfo[@"type"];
    NSArray *chatMembers = _chatInfo[@"members"];
    
    for (NSString *userId in chatMembers) {
        
        Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, userId]];
        
        if ([chatType isEqualToString:@"private"]) {
            if ([userId isEqualToString:[PFUser currentUser].objectId]) {
                [firebase updateChildValues:@{groupId : _chatInfo}];
            } else {
                PFUser *currentUser = [PFUser currentUser];
                PFFile *userImage = currentUser[PF_USER_PICTURE];
                [firebase updateChildValues:@{groupId : @{@"groupId" : groupId, @"date" : _chatInfo[@"date"], @"title" : currentUser[PF_USER_DISPLAYNAME], @"members" : chatMembers, @"imageURL" : userImage.url, @"type" : @"private", @"admin" : currentUser.objectId}}];
            }
        } else {
            [firebase updateChildValues:@{groupId : _chatInfo}];
        }
    }
}

-(void) p_setNewMessageCount
{
    [self.delegate incrementedNewMessageCount:0 ForChat:self.groupId];
    self.newMessageCount = 0;
}

-(void) p_sendMessageNotifications
{
    NSMutableArray *chatMembers = _chatInfo[@"members"];
    NSString *groupId = self.groupId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    
    if (self.allMessages.count == 0 || self.allMessages == nil) {
        [self p_updateFirebaseInformation];
    }
    
    for (NSString *userId in chatMembers) {
        
        if (![userId isEqualToString:currentUserId]) {
            [PushNotifications sendNotificationToUser:userId forGroupId:groupId];
        }
    }
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.chatInfo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatInfo))];
    } else {
        return nil;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.chatInfo forKey:NSStringFromSelector(@selector(chatInfo))];
}

#pragma mark - Method Overrides

-(void) sendAudioMessageWithUrl:(NSURL *)url
{
    [super sendAudioMessageWithUrl:url];
    [self p_sendMessageNotifications];
}

-(void) sendPictureMessageWithImage:(UIImage *)image
{
    [super sendPictureMessageWithImage:image];
    [self p_sendMessageNotifications];
}

-(void) sendVideoMessageWithURL:(NSURL *)url
{
    [super sendVideoMessageWithURL:url];
    [self p_sendMessageNotifications];
}

#pragma mark - Setter Methods

-(void) setChatImage:(UIImage *)chatImage
{
    _chatImage = chatImage;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:chatImage];
    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailsButtonPressed:)];
    [imageView addGestureRecognizer:tapGesture];
    
    UIBarButtonItem *chatImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(detailsButtonPressed:)];
    chatImageButton.customView = imageView;
    
    [self.navigationItem setRightBarButtonItem:chatImageButton animated:YES];
}

#pragma mark - Touch Handling
-(void)detailsButtonPressed:(UIBarButtonItem *)sender
{
    IDMPhoto *photo = [IDMPhoto photoWithImage:self.chatImage];
    IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

@end
