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

#import <Firebase/Firebase.h>

@interface LMPrivateChatViewController ()

@property (strong, nonatomic) NSDictionary *chatInfo;
@property (copy, nonatomic) NSString *baseAddress;

@property (strong, nonatomic) NSDictionary *profileVCs;

@end

@implementation LMPrivateChatViewController

#pragma mark - View Controller LifeCycle

-(instancetype) initWithFirebaseAddress:(NSString *)address groupId:(NSString *)groupId andChatInfo:(NSDictionary *)info
{
    if (self = [super initWithFirebaseAddress:address andGroupId:groupId]) {
        if (info != nil) {
            _baseAddress = address;
            _chatInfo = info;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *chatImageButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Details", @"Details") style:UIBarButtonItemStylePlain target:self action:nil];
    [self.navigationItem setRightBarButtonItem:chatImageButton animated:YES];
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
        
        NSMutableArray *receiverIds = [[NSMutableArray alloc] init];
        
        if ([_chatInfo[@"member"] isKindOfClass:[NSArray class]]) {
            
            for (NSString *userId in _chatInfo[@"member"]) {
                if (![userId isEqualToString:[PFUser currentUser].objectId]) {
                    [receiverIds addObject:userId];
                }
            }
            
        } else {
            [receiverIds addObject:_chatInfo[@"member"]];
        }
        
        NSString *groupId = self.groupId;
        
        for (NSString *user in receiverIds) {
            
            if (self.allMessages.count == 0 || self.allMessages == nil) {
                [self p_updateFirebaseInformation];
                [PushNotifications sendChatRequestToUser:user forGroupId:groupId];
                
            } else {
                [PushNotifications sendNotificationToUser:user forGroupId:groupId];
            }
        }
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
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupId = self.groupId;
    NSString *title = _chatInfo[@"title"];
    NSString *date = _chatInfo[@"date"];
    
    if ([_chatInfo[@"member"] isKindOfClass:[NSArray class]]) {
        
        NSArray *groupMemberIds = _chatInfo[@"member"];
        
        NSData *chatImageData = UIImageJPEGRepresentation(_chatInfo[@"image"], 0.7);
        PFFile *chatImage = [PFFile fileWithData:chatImageData];
        
        [chatImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                for (NSString *userId in _chatInfo[@"member"]) {
                    Firebase *theirFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, userId]];
                    [theirFirebase updateChildValues:@{groupId : @{@"title" : title, @"member" : groupMemberIds, @"date" : date, @"admin" : _chatInfo[@"admin"], @"image" : chatImage.url}}];
                }
                
            } else {
                NSLog(@"%@", [NSString lm_parseError:error]);
            }
        }];
        
    } else {
        
        NSString *receiver = _chatInfo[@"member"];

        Firebase *theirFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, receiver]];
        [theirFirebase updateChildValues:@{groupId : @{@"title" : currentUser[PF_USER_DISPLAYNAME], @"member" : currentUser.objectId, @"date" : date}}];
        
        Firebase *myFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, currentUser.objectId]];
        [myFirebase updateChildValues:@{groupId : @{@"title" : title, @"member" : receiver, @"date" : date}}];
    }
}

-(void) p_setNewMessageCount
{
    [self.delegate incrementedNewMessageCount:0 ForChat:self.groupId];
    self.newMessageCount = 0;
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



@end
