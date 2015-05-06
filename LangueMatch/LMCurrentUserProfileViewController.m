//
//  LMCurrentUserProfileViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/5/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMCurrentUserProfileViewController.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"
#import "AppConstant.h"
#import "LMParseConnection.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithSelection)(NSString *language);

@interface LMCurrentUserProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation LMCurrentUserProfileViewController

static NSString *cellIdentifier = @"myCell";

-(instancetype)initWith:(PFUser *)user
{
    if (self = [super initWith:[PFUser currentUser]]){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"profile.png"]];
    self.tabBarItem.title = @"Profile";
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(didTapCameraButton:)];
    [self.navigationItem setRightBarButtonItem:cameraButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *accessoryView = cell.accessoryView;
    
    accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
    
    [UIView animateWithDuration:1.0 animations:^{
        accessoryView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        switch (indexPath.section) {
            case 0:
                [self changeUsernameWithCompletion:^(NSString *username) {
                    NSLog(@"Change Name");
                }];
                break;
            case 1:
                [self changeLanguageType:LMLanguageChoiceTypeFluent withCompletion:^(NSString *language) {
                    NSLog(@"Change Fluent Language");
                }];
                break;
            case 2:
                [self changeLanguageType:LMLanguageChoiceTypeDesired withCompletion:^(NSString *language) {
                    NSLog(@"Change Desired Language");
                }];
                break;
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
    cell.accessoryView = accessoryView;
    cell.userInteractionEnabled = YES;

    return cell;
    
}

#pragma mark - Touch Handling


-(void)didTapCameraButton:(UIBarButtonItem *)sender
{
    UIAlertController *cameraSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger selection) {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = selection;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraSourceTypeAlert animated:YES completion:nil];
}

-(void) changeLanguageType:(LMLanguageChoiceType)type withCompletion:(LMCompletedWithSelection)completion
{
    UIAlertController *chooseLanguage = [LMAlertControllers chooseLanguageAlertWithCompletionHandler:^(NSInteger language) {
        NSString *languageChoice = [LMGlobalVariables LMLanguageOptions][language];
        completion(languageChoice);
        [LMParseConnection saveUserLanguageSelection:language forType:type];
    }];
    
    [self presentViewController:chooseLanguage animated:YES completion:nil];
}

-(void) changeUsernameWithCompletion:(LMCompletedWithUsername)completion
{
    UIAlertController *changeUsernameAlert = [LMAlertControllers changeUsernameAlertWithCompletion:^(NSString *username) {
        if (username.length != 0)
        {
            //Need to make sure username is not taken
            completion(username);
            [LMParseConnection saveUsersUsername:username];
        }
    }];
    
    [self presentViewController:changeUsernameAlert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [LMParseConnection saveUserProfileImage:editedImage];
    self.profilePicView.image = editedImage;
}

@end
