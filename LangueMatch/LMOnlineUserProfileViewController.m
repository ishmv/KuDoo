//
//  LMOnlineUserProfileViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMOnlineUserProfileViewController.h"
#import "UIColor+applicationColors.h"
#import "NSString+Chats.h"

#import <Firebase/Firebase.h>

#define kFirebaseUsersAddress @"https://langMatch.firebaseio.com/users/"

@interface LMOnlineUserProfileViewController ()

@end

@implementation LMOnlineUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 45)];
        [footerView setUserInteractionEnabled:YES];
        
        UIButton *sayHeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sayHeyButton.frame = CGRectMake(25, 0, CGRectGetWidth(self.view.frame) - 50, 45);
        sayHeyButton.backgroundColor = [UIColor lm_alizarinColor];
        [sayHeyButton setTitle:@"Ask To Chat" forState:UIControlStateNormal];
        [sayHeyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sayHeyButton addTarget:self action:@selector(sendChatRequestPressed:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:sayHeyButton];
        
        return footerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) return 45.0f;
    return 5.0f;
}

-(void) sendChatRequestPressed:(UIBarButtonItem *)sender
{
    NSString *userId = self.user.objectId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    NSString *groupId = [NSString lm_createGroupIdWithUsers:@[userId, currentUserId]];
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    Firebase *userFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/requests", kFirebaseUsersAddress, userId]];
    
    NSDictionary *requestInfo = @{@"groupId" : groupId, @"requestorId" : currentUserId, @"requestorName" : [PFUser currentUser].username , @"responded" : @NO , @"date" : dateString};
    [userFirebase setValue:@{currentUserId : requestInfo}];
}

@end
