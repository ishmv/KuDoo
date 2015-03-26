#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "LMHomeScreenViewController.h"
#import "LMLoginView.h"
#import "Parse/Parse.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

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
    // Do any additional setup after loading the view.
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
    [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self.delegate userPressedLoginButton];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Login", @"Invalid Login")
                                                            message:NSLocalizedString(@"Try Again", @"Please Try Again or Sign Up for an Account")
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"SignUp", nil];
            [alert show];
        }
    }];
}

-(void)userPressedSignUpButton:(UIButton *)button
{
    [self presentSignUpViewController];
}


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
            [self.delegate userPressedLoginButton];
        }
    }];
    
//    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
    
}

#pragma mark - Presenting View Controllers

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

#pragma mark - Facebook Login


@end
