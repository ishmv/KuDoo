//
//  LMSearchedUserProfileViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/5/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSearchedUserProfileViewController.h"
#import "LMParseConnection.h"
#import "LMGlobalVariables.h"
#import "LMAlertControllers.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LMSearchedUserProfileViewController ()

@end

@implementation LMSearchedUserProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    UIBarButtonItem *startNewChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:startNewChatButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch handling

-(void)actionButtonPressed: (UIBarButtonItem *)sender
{
    UIAlertController *alertController = [LMAlertControllers sendRequestToUserAlertWithCompletion:^(NSInteger type) {
        switch (type) {
            case LMRequestTypeFriend:
                [LMParseConnection sendUser:self.user request:type withCompletion:^(BOOL sent, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Friend Request Sent", @"Friend Request Send")];
                }];
                break;
                
            default:
                break;
        }
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
