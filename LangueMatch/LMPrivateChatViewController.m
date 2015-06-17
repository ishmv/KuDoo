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

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>

@interface LMPrivateChatViewController ()

@property (strong, nonatomic) NSDictionary *chatInfo;
@property (copy, nonatomic) NSString *baseAddress;

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
}

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [super messagesInputToolbar:toolbar didPressRightBarButton:sender];
    
    if (sender == self.sendButton) {
        NSString *receiver = _chatInfo[@"member"];
        NSString *groupId = self.groupId;
        
        if (self.allMessages.count == 0 || self.allMessages == nil) {
            [self p_updateFirebaseInformation];
            [PushNotifications sendChatRequestToUser:receiver forGroupId:groupId];
        } else {
            [PushNotifications sendNotificationToUser:receiver forGroupId:groupId];
        }
    }
}

#pragma mark - Private Methods

-(void) p_updateFirebaseInformation
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupId = self.groupId;
    NSString *receiver = _chatInfo[@"member"];
    NSString *title = _chatInfo[@"title"];
    NSString *date = _chatInfo[@"date"];
    
    Firebase *theirFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, receiver]];
    [theirFirebase updateChildValues:@{groupId : @{@"title" : currentUser[PF_USER_DISPLAYNAME], @"member" : currentUser.objectId, @"date" : date}}];
    
    Firebase *myFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/chats", _baseAddress, currentUser.objectId]];
    [myFirebase updateChildValues:@{groupId : @{@"title" : title, @"member" : receiver, @"date" : date}}];
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
