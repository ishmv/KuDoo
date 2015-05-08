//
//  LMFriendRequestUserProfileViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/6/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMFriendRequestUserProfileViewController.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendRequestUserProfileViewController ()

@property (strong, nonatomic) PFObject *request;

@end

@implementation LMFriendRequestUserProfileViewController

-(instancetype) initWithRequest:(PFObject *)request
{
    PFUser *user;
    
    PFUser *currentUser = [PFUser currentUser];
    user = (request[PF_FRIEND_REQUEST_RECEIVER] == currentUser) ? request[PF_FRIEND_REQUEST_SENDER] : request[PF_FRIEND_REQUEST_RECEIVER];
    
    _request = request;
    
    if (self = [super initWith:user]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (_request[PF_FRIEND_REQUEST_SENDER] != currentUser)
    {
        UIBarButtonItem *acceptRequest = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(acceptButtonPressed:)];
    
        UIBarButtonItem *declineRequest = [[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStylePlain target:self action:@selector(declineButtonPressed:)];
        [self.navigationItem setRightBarButtonItems:@[acceptRequest, declineRequest]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Handling

-(void) acceptButtonPressed:(UIBarButtonItem *)sender
{
    [self.delegate userAcceptedFriendRequest:_request];
}

-(void) declineButtonPressed:(UIBarButtonItem *)sender
{
    [self.delegate userDeclinedFriendRequest:_request];
}

@end
