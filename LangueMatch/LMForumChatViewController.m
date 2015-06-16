//
//  LMForumChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMForumChatViewController.h"

@interface LMForumChatViewController ()

@property (strong, nonatomic) UIBarButtonItem *chatImageButton;

@end

@implementation LMForumChatViewController

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId
{
    if (self = [super initWithFirebaseAddress:address andGroupId:groupId]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter Methods

-(void) setChatImage:(UIImage *)chatImage
{
    _chatImage = chatImage;
    
    if (!_chatImageButton) {
        self.chatImageButton = [[UIBarButtonItem alloc] initWithImage:chatImage style:UIBarButtonItemStylePlain target:self action:nil];
    }
    
//    [self.navigationItem setRightBarButtonItem:_chatImageButton animated:YES];
    
}

@end
