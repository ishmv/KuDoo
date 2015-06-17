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
#import "Utility.h"

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
    if (section == 4) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 45)];
        [footerView setUserInteractionEnabled:YES];
        
        UIButton *sayHeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sayHeyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [sayHeyButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [sayHeyButton.layer setCornerRadius:10.0f];
        [sayHeyButton.layer setMasksToBounds:YES];
        sayHeyButton.backgroundColor = [UIColor lm_tealColor];
        [sayHeyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sayHeyButton addTarget:self action:@selector(initiateChat:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:sayHeyButton];
        
        CENTER_VIEW_H(footerView, sayHeyButton);
        ALIGN_VIEW_BOTTOM(footerView, sayHeyButton);
        CONSTRAIN_HEIGHT(sayHeyButton, 45);
        CONSTRAIN_WIDTH(sayHeyButton, 150);
        
        return footerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4) return 55.0f;
    return 5.0f;
}

-(void) initiateChat:(UIBarButtonItem *)sender
{
    NSString *userId = self.user.objectId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    NSString *groupId = [NSString lm_createGroupIdWithUsers:@[userId, currentUserId]];
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSDictionary *chatInfo = @{@"groupId" : groupId, @"date" : dateString, @"title" : self.user[PF_USER_DISPLAYNAME], @"member" : userId};
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:chatInfo];
}

@end
