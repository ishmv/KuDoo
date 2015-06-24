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
#import "UIButton+TapAnimation.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface LMOnlineUserProfileViewController ()

@property (strong, nonatomic) UIButton *optionsButton;

@end

@implementation LMOnlineUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.optionsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [self.optionsButton addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.optionsButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 45, CGRectGetHeight(self.view.frame)/3.0 - 45, 40, 40);
    self.optionsButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.optionsButton.layer setCornerRadius:20.0f];
    self.optionsButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    [self.optionsButton.layer setMasksToBounds:YES];
    [self.view addSubview:self.optionsButton];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *userId = self.user.objectId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    NSString *groupId = [NSString lm_createGroupIdWithUsers:@[userId, currentUserId]];
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSDictionary *chatInfo = @{@"groupId" : groupId, @"date" : dateString, @"title" : self.user[PF_USER_DISPLAYNAME], @"member" : userId};
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:chatInfo];
}

-(void) optionsButtonTapped:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    UIAlertController *options = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", @"Options") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *sendMessageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Message", @"Send Message") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self initiateChat:nil];
    }];
    
    UIAlertAction *reportUser = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report User", @"Report User") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Report User", @"Report User") message:NSLocalizedString(@"Please add a reason", @"Please add a reason") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *sendEmailAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report", @"Report") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *emailTextField = forgotPasswordAlert.textFields[0];
            
            PFObject *complaint = [PFObject objectWithClassName:LM_USER_COMPLAINT];
            complaint[LM_USER_COMPLAINER] = [PFUser currentUser];
            complaint[LM_USER_COMPLAINEE] = self.user;
            complaint[LM_USER_COMPLAINT_REASON] = emailTextField.text;
            
            [complaint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil) {
                    NSLog(@"error sending report user request %@", error.description);
                }
                else
                {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.labelText = NSLocalizedString(@"Thank you - Report Sent", @"Report Sent");
                    hud.mode = MBProgressHUDModeText;
                    [hud hide:YES afterDelay:2.0];
                }
            }];
        }];
        
        for (UIAlertAction *action in @[cancelAction2, sendEmailAction]) {
            [forgotPasswordAlert addAction:action];
        }
        
        [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Reason", @"Reason");
        }];
        
        [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
    }];
    
    for (UIAlertAction *action in @[cancelAction1, sendMessageAction, reportUser]) {
        [options addAction:action];
    }
    
    [self presentViewController:options animated:YES completion:nil];
}


@end
