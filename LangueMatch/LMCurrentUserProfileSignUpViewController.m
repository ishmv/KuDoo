//
//  LMCurrentUserProfileSignUpViewController.m
//  simplechat
//
//  Created by Travis Buttaccio on 6/3/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMCurrentUserProfileSignUpViewController.h"
#import "AppConstant.h"
#import "Utility.h"

#import <Parse/Parse.h>

@interface LMCurrentUserProfileSignUpViewController ()

@property (strong, nonatomic) UIButton *endCustomize;

@end

@implementation LMCurrentUserProfileSignUpViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWith:[PFUser currentUser]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.endCustomize = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCustomize.frame = CGRectMake(0, 0, 200, 100);
    [self.endCustomize setTitle:@"Finished." forState:UIControlStateNormal];
    self.endCustomize.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCustomize.backgroundColor = [UIColor lightGrayColor];
    [self.endCustomize setUserInteractionEnabled:YES];
    [self.view addSubview:self.endCustomize];
    
    [self.endCustomize addTarget:self action:@selector(userFinished) forControlEvents:UIControlEventTouchUpInside];
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

-(void) userFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

@end
