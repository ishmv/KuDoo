//
//  LMSignUpProfileViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/10/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSignUpProfileView.h"
#import "AppConstant.h"
#import "Utility.h"
#import "UIButton+TapAnimation.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"

#import <Parse/Parse.h>

@interface LMSignUpProfileView ()

@property (strong, nonatomic) UIButton *endCustomize;

@end

@implementation LMSignUpProfileView

-(instancetype) initWithUser:(PFUser *)user {
    
    if (self = [super initWithUser:user]) {
        [self p_fetchUserInformation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.endCustomize = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCustomize.frame = CGRectZero;
    [self.endCustomize setTitle:NSLocalizedString(@"Finished", @"finished") forState:UIControlStateNormal];
    self.endCustomize.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.endCustomize setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.endCustomize.titleLabel setFont:[UIFont lm_noteWorthyMedium]];
    [self.endCustomize.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.endCustomize.layer setBorderWidth:1.0f];
    [self.endCustomize.layer setBackgroundColor:[UIColor lm_tealBlueColor].CGColor];
    [self.endCustomize.layer setMasksToBounds:YES];
    
    [self.view addSubview:self.endCustomize];
    
    [self.endCustomize addTarget:self action:@selector(userPressedFinishedButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.endCustomize];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CONSTRAIN_HEIGHT(_endCustomize, 50);
    CONSTRAIN_WIDTH(_endCustomize, CGRectGetWidth(self.view.frame) - 30);
    CENTER_VIEW_H(self.view, _endCustomize);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.view, _endCustomize, -8);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Handling

-(void) userPressedFinishedButton:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

#pragma mark - Network Fetch

-(void) p_fetchUserInformation
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.userInformation reloadData];
    }];
}

@end

