#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "AppConstant.h"
#import "NSString+Chats.h"
#import "ParseConnection.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface LMLoginViewController ()

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

#pragma mark - LMLogin Delegate

-(void)LMUser:(NSString *)username pressedLoginButton:(UIButton *)button withPassword:(NSString *)password
{
    [ParseConnection loginUser:username withPassword:password withCompletion:^(PFUser *user, NSError *error) {
        if (error != nil)
        {
            [self p_showHUDWithError:error];
        }
        else
        {
            [self.delegate loginViewController:self didLoginUser:user];
        }
    }];
}

-(void)userPressedSignUpButton:(UIButton *)button
{
    [self presentSignUpViewController];
}

-(void)userPressedForgotPasswordButton:(UIButton *)button
{
    UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter the email linked with your account", @"Enter Email") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *sendEmailAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"Send") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *emailTextField = forgotPasswordAlert.textFields[0];
        
        [PFUser requestPasswordResetForEmailInBackground:emailTextField.text block:^(BOOL succeeded, NSError *error) {
            if (error != nil)
            {
                [self p_showHUDWithError:error];
            }
            else
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = NSLocalizedString(@"You should be receiving an email shortly", @"You should be receiving an email shortly");
                [hud hide:YES afterDelay:2.0];
            }
        }];
    }];
    
    for (UIAlertAction *action in @[cancelAction, sendEmailAction]) {
        [forgotPasswordAlert addAction:action];
    }
    
    [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"email", @"email");
    }];
    
    [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
    
}

#pragma mark - Present Sign Up View Controller

-(void) presentSignUpViewController
{
    if (!_signUpVC) {
        self.signUpVC = [[LMSignUpViewController alloc] init];
    }
    
    [self.navigationController pushViewController:self.signUpVC animated:YES];
}

#pragma mark - Private Methods
-(void) p_showHUDWithError:(NSError *)error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString lm_parseError:error];
    [hud hide:YES afterDelay:2.0];
}


#pragma mark -Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
