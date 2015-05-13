#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "LMLoginView.h"
#import "AppConstant.h"
#import "LMGlobalVariables.h"

#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"
#import "LMParseConnection.h"

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
    
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


#pragma mark - LMLoginView Delegate

-(void)LMUser:(NSString *)username pressedLoginButton:(UIButton *)button withPassword:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Signing In"];
    
    [LMParseConnection loginUser:username withPassword:password withCompletion:^(PFUser *user, NSError *error) {
        if (error.code == TBParseError_ObjectNotFound)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"The username/password combination does not match our records. Please try again or tap signup below", @(error.code)) maskType:SVProgressHUDMaskTypeClear];
        }
        else if (error.code == TBParseError_ConnectionFailed)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Unable to connect - Please check your internet connection", @(error.code)) maskType:SVProgressHUDMaskTypeClear];
        }
        else if (!error)
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

-(void)userPressedForgotPasswordButton:(UIButton *)button
{
    UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter the email linked with your LangueMatch account", @"Enter Email") message:NSLocalizedString(@"Password reset instructions will be emailed to you", @"Email will be sent") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *sendEmailAction = [UIAlertAction actionWithTitle:@"Send Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *emailTextField = forgotPasswordAlert.textFields[0];
        
        [PFUser requestPasswordResetForEmailInBackground:emailTextField.text block:^(BOOL succeeded, NSError *error) {
            if (error.code == TBParseError_UserWithEmailNotFound)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"That email does not seem to be linked with any LangueMatch accounts. Please Try Again.", @(error.code)) maskType:SVProgressHUDMaskTypeClear];
            }
            else if (error.code == TBParseError_ConnectionFailed)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Unable to connect - Please check your internet connection", @(error.code)) maskType:SVProgressHUDMaskTypeClear];
            }
            else if (error.code == TBParseError_InvalidEmailAddress)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Invalid Email Address", @(error.code)) maskType:SVProgressHUDMaskTypeClear];
            }
            else if (!error)
            {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thank You. Password reset instructions will be sent to you shortly", @"Email Sent") maskType:SVProgressHUDMaskTypeClear];
            }
        }];
    }];
    
    for (UIAlertAction *action in @[cancelAction, sendEmailAction]) {
        [forgotPasswordAlert addAction:action];
    }
    
    [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter Email";
    }];
    
    [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
    
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
