#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "LMLoginView.h"
#import "AppConstant.h"

#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"

#import <SVProgressHUD.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface LMLoginViewController () <LMLoginViewDelegate>

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
    
    self.loginView = [[LMLoginView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.loginView.delegate = self;
    [self.view addSubview:self.loginView];
    
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
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[PF_INSTALLATION_USER] = [PFUser currentUser];
            [installation saveInBackground];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
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
    [self.navigationController pushViewController:signUpVC animated:YES];
}


#pragma mark -Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
