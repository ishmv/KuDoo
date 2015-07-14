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
@property (strong, nonatomic) UIButton *sendMessageButton;

@end

@implementation LMOnlineUserProfileViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.optionsButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [button.layer setCornerRadius:22.0f];
        button.backgroundColor = [[UIColor lm_orangeColor] colorWithAlphaComponent:0.7f];
        [button.layer setMasksToBounds:YES];
        button;
    });
    
    self.sendMessageButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(initiateChat:) forControlEvents:UIControlEventTouchUpInside];
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [button.layer setCornerRadius:22.0f];
        button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
        [button.layer setMasksToBounds:YES];
        button;
    });
    
    for (UIView *view in @[self.optionsButton, self.sendMessageButton]) {
        [self.view addSubview:view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat backgroundImageHeight = CGRectGetHeight(self.view.frame)/2.0;
    
    self.optionsButton.frame = CGRectMake(viewWidth - 52, backgroundImageHeight/2.0 - 22.0, 44, 44);
    self.sendMessageButton.frame = CGRectMake(viewWidth - 52, backgroundImageHeight/2.0 + 38, 44, 44);
}

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

-(void) initiateChat:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupId = [NSString lm_createGroupIdWithUsers:@[self.user.objectId, currentUser.objectId]];
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    PFFile *theirImageFile = self.user[PF_USER_PICTURE];
    NSDictionary *myInfo = @{@"groupId" : groupId, @"date" : dateString, @"title" : self.user[PF_USER_DISPLAYNAME], @"members" : @[currentUser.objectId, self.user.objectId], @"imageURL" : theirImageFile.url, @"type" : @"private", @"admin" : currentUser.objectId};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:myInfo];
}

-(void) optionsButtonTapped:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    UIAlertController *options = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", @"options") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *sendMessageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Message", @"send message") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self initiateChat:nil];
    }];
    
    UIAlertAction *reportUser = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report User", @"report user") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Report User", @"report user") message:NSLocalizedString(@"Add a reason", @"add a reason") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report User", @"report user") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
                    hud.color = [UIColor whiteColor];
                    [hud hide:YES afterDelay:2.0];
                }
            }];
        }];
        
        
        for (UIAlertAction *action in @[cancelAction2, reportUserAction]) {
            [forgotPasswordAlert addAction:action];
        }
        
        [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Reason", @"reason");
        }];
        
        [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
    }];
    
    UIAlertAction *blockUserAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Block User", @"block user") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BLOCK_USER object:self.user.objectId];
    }];
    
    
    for (UIAlertAction *action in @[cancelAction1, sendMessageAction, reportUser, blockUserAction]) {
        [options addAction:action];
    }
    
    [self presentViewController:options animated:YES completion:nil];
}


@end
