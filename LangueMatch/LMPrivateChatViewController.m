//
//  LMPrivateChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMPrivateChatViewController.h"
#import "AppConstant.h"

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>

#define kFirebaseUsersAddress @"https://langMatch.firebaseio.com/users/"

@interface LMPrivateChatViewController ()

@property (strong, nonatomic) NSDictionary *request;

@end

@implementation LMPrivateChatViewController

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId fromRequest:(NSDictionary *)request
{
    if (self = [super initWithFirebaseAddress:address andGroupId:groupId]) {
        self.archiveMessages = YES;
        _request = request;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [super didPressSendButton:button withMessageText:text senderId:senderId senderDisplayName:senderDisplayName date:date];
    
    if (self.allMessages.count == 0) {
        [self p_updateFirebaseInformation];
    }
}

#pragma mark - Private Methods

// Sets request field to "responded" = @"YES and adds chat to both user's firebase

-(void) p_updateFirebaseInformation
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupId = _request[@"groupId"];
    NSString *requestorId = _request[@"requestorId"];
    NSString *requestorName = _request[@"requestorName"];
    
    Firebase *userFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/chats", kFirebaseUsersAddress, requestorId]];
    [userFirebase updateChildValues:@{groupId : @{@"title" : currentUser.username, @"members" : @[currentUser.objectId, requestorId]}}];
    
    Firebase *myFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/chats", kFirebaseUsersAddress, currentUser.objectId]];
    [myFirebase updateChildValues:@{groupId : @{@"title" : requestorName, @"members" : @[currentUser.objectId, requestorId]}}];
    
    Firebase *requestFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/requests", kFirebaseUsersAddress, currentUser.objectId]];
    [requestFirebase updateChildValues:@{requestorId : @{@"responded" : @YES}}];
}

@end
