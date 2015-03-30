#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "LMLoginView.h"

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
    self.loginView = [[LMLoginView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.loginView.delegate = self;
    [self.view addSubview:self.loginView];
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
            if ([self.delegate respondsToSelector:@selector(userSuccessfullyLoggedIn)]) {
                [self.delegate userSuccessfullyLoggedIn];
            }
        }
    }];
}

-(void)userPressedSignUpButton:(UIButton *)button
{
    [self presentSignUpViewController];
}


#pragma mark - Facebook Login
/*
 
 Incomplete - If user is new grab contacts, search for Langue Match users and add to friends list
 
*/

-(void)userPressedLoginWithFacebookButton:(UIButton *)button
{
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
           
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self.delegate userSuccessfullyLoggedIn];
        }
    }];
}

#pragma mark - Present Sign Up View Controller

-(void) presentSignUpViewController
{
    LMSignUpViewController *signUpVC = [[LMSignUpViewController alloc] init];
    signUpVC.delegate = self;
    [self.navigationController pushViewController:signUpVC animated:YES];
}

-(void)userSuccessfullySignedUp
{
    [self.delegate userSuccessfullyLoggedIn];
}


#pragma mark -Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
