//
//  LMRandomChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMRandomChatViewController.h"
#import "Utility.h"

@interface LMRandomChatViewController()

@property (strong, nonatomic) PFObject *chat;

@end

@implementation LMRandomChatViewController

-(instancetype) initWithChat:(PFObject *)chat
{
    if (self = [super initWithChat:chat]) {
        _chat = chat;
    }
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Chat" style:UIBarButtonItemStylePlain target:self action:@selector(userPressedBackButton:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
}

#pragma mark - Touch Handling

-(void) userPressedBackButton:(UIBarButtonItem *)sender
{
    [self.inputToolbar endEditing:YES];
    [self.delegate userEndedChat:_chat];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
