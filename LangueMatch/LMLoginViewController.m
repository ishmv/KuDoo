#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "LMLoginView.h"

#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LMLoginViewController () <LMLoginViewDelegate, LMSignUpViewControllerDelegate>

@property (strong, nonatomic) LMLoginView *loginView;

@end

@implementation LMLoginViewController

-(instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        [self startSession];
    }
    else
    {
        self.loginView = [[LMLoginView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.loginView.delegate = self;
        [self.view addSubview:self.loginView];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


#pragma mark - LMLoginView Delegate

-(void)PFUser:(PFUser *)user pressedLoginButton:(UIButton *)button
{
    [SVProgressHUD show];
    
    [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser *user, NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(error.description, err.description) maskType:SVProgressHUDMaskTypeClear];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome Back!", @"Welcome Back!") maskType:SVProgressHUDMaskTypeClear];
            [self userSuccessfullyLoggedIn];
        }
    }];
}

-(void)userPressedSignUpButton:(UIButton *)button
{
    [self presentSignUpViewController];
}


#pragma mark - Present Sign Up View Controller

-(void) presentSignUpViewController
{
    LMSignUpViewController *signUpVC = [[LMSignUpViewController alloc] init];
    signUpVC.delegate = self;
    [self.navigationController pushViewController:signUpVC animated:YES];
}

#pragma mark - LMSignUpViewController Delegate

-(void)userSuccessfullySignedUp
{
    //Get contacts from phone
    //If facebook user get contacts can include as payload
    NSLog(@"Funneled through here");
    
    //Get contacts from facebook
    
    [self userSuccessfullyLoggedIn];
}


#pragma mark - Post Sign Up/In

-(void) userSuccessfullyLoggedIn
{
    NSLog(@"Funnel");
    [self startSession];
}


-(void) presentHomeScreen
{
    NSLog(@"Present Home Screen");
}


-(void)startSession
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    LMFriendsListViewController *friendsListVC = [[LMFriendsListViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:friendsListVC];
    
    LMChatsListViewController *chatsListVC = [[LMChatsListViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:chatsListVC];
    
    LMUserProfileViewController *profileVC = [[LMUserProfileViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    [tabBarController setViewControllers:@[nav1, nav2, nav3] animated:YES];
    [self presentViewController:tabBarController animated:YES completion:nil];
}

#pragma mark -Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
