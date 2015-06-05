#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"
#import "LMParseConnection.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface LMSignUpViewController () <LMSignUpViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) LMSignUpView *signUpView;

@end

@implementation LMSignUpViewController

-(instancetype)init
{
    if (self = [super init]){
    }
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.signUpView = [[LMSignUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.signUpView.delegate = self;
    
    for (UIView *view in @[self.signUpView]) {
        [self.view addSubview:view];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - LMSignUpView Delegate

-(void) userWithCredentials:(NSDictionary *)info pressedSignUpButton:(UIButton *)sender
{
    PFUser *user = [PFUser user];
    user.username = info[PF_USER_USERNAME];
    user.password = info[PF_USER_PASSWORD];
    user.email = info[PF_USER_EMAIL];
    
    [LMParseConnection signupUser:user withCompletion:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             [self p_showHUDWithError:error];
         }
         else if (succeeded)
         {
            [self.delegate signupViewController:self didSignupUser:user];
         }
     }];
}


-(void) facebookButtonPressed:(UIButton *)sender
{
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (error)
        {
            [self p_showHUDWithError:error];
        }
        else
        {
            if (user.isNew) {
                if ([FBSDKAccessToken currentAccessToken]) {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error)
                        {
                            NSDictionary *userData = (NSDictionary *)result;
                            
                            NSString *facebookID = userData[@"id"];
                            NSString *fullName = userData[@"name"];
                            NSString *email = userData[@"email"];
                            NSArray *friends = userData[@"friends"];
                            
                            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                            
                            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                            [NSURLConnection sendAsynchronousRequest:urlRequest
                                                               queue:[NSOperationQueue mainQueue]
                                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                       
                                                       UIImage *profileImage = [UIImage imageWithData:data];
                                                       [LMParseConnection saveUserImage:profileImage forType:LMUserPictureSelf];
                                                   }];
                            
                            user[PF_USER_EMAIL] = email;
                            user[PF_USER_USERNAME] = fullName;
                            user[PF_USER_USERNAME_LOWERCASE] = [fullName lowercaseString];
                            user[PF_USER_EMAILCOPY] = [email lowercaseString];
                            user[PF_USER_AVAILABILITY] = @(YES);
                            [user saveInBackground];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                            message:@"LangueMatch is linked with your Facebook account"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"COOL!"
                                                                  otherButtonTitles: nil];
                            [alert show];
                            
                            if (friends.count != 0) {
                                
                            }
                            
                        }
                    }];
                }
                
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
        }
    }];
    
}


-(void) hasAccountButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private Methods

-(void) p_showHUDWithError:(NSError *)error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [LMGlobalVariables parseError:error];
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0];
}



-(void) registerForRemoteNotifications
{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}



#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
