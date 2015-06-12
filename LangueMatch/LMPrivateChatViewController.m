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

#define kFirebaseUsersAddress @"https://langMatch.firebaseio.com/users/"

@interface LMPrivateChatViewController ()

@property (strong, nonatomic) NSDictionary *info;

@end

@implementation LMPrivateChatViewController

-(instancetype) initWithFirebaseAddress:(NSString *)address groupId:(NSString *)groupId andChatInfo:(NSDictionary *)info
{
    if (self = [super initWithFirebaseAddress:address andGroupId:groupId]) {
        if (info != nil) {
            _info = info;
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

-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSString *receiver = _info[@"member"];
    
    [super didPressSendButton:button withMessageText:text senderId:senderId senderDisplayName:senderDisplayName date:date];
    
    if (self.allMessages.count == 0 || self.allMessages == nil) {
        [self p_updateFirebaseInformation];
        [PushNotifications sendChatRequestToUser:receiver];
    } else {
        [PushNotifications sendNotificationToUser:receiver];
    }
}

#pragma mark - Private Methods

-(void) p_updateFirebaseInformation
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupId = self.groupId;
    NSString *receiver = _info[@"member"];
    NSString *title = _info[@"title"];
    NSString *date = _info[@"date"];
    
    Firebase *theirFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/chats", kFirebaseUsersAddress, receiver]];
    [theirFirebase updateChildValues:@{groupId : @{@"title" : currentUser.username, @"member" : currentUser.objectId, @"date" : date}}];
    
    Firebase *myFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/chats", kFirebaseUsersAddress, currentUser.objectId]];
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
        self.info = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(info))];
    } else {
        return nil;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.info forKey:NSStringFromSelector(@selector(info))];
}


@end
