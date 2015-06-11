#import "LMSignUpViewController.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "NSString+Chats.h"
#import "ParseConnection.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface LMSignUpViewController ()

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
    
    [ParseConnection signupUser:user withCompletion:^(BOOL succeeded, NSError *error)
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
                            
                            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                            
                            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                            [NSURLConnection sendAsynchronousRequest:urlRequest
                                                               queue:[NSOperationQueue mainQueue]
                                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                       UIImage *profileImage = [UIImage imageWithData:data];
                                                       [ParseConnection saveUserImage:profileImage forType:LMUserPictureSelf];
                                                   }];
                            
                            user.email = email;
                            user.username = fullName;
                            user[PF_USER_USERNAME_LOWERCASE] = [fullName lowercaseString];
                            user[PF_USER_EMAILCOPY] = [email lowercaseString];
                            user[PF_USER_ONLINE] = @(YES);
                            [user saveInBackground];
                            
                            [self.delegate signupViewController:self didSignupUser:user];
                        }
                    }];
                }
            } else {
                NSLog(@"User with facebook logged in!");
            }
        }
    }];
    
}

-(void) twitterButtonPressed:(UIButton *)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
            
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            [manager GET:[url absoluteString] parameters:@{@"screen_name" : @"buttacciot"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed");
            }];
            
            [self.delegate signupViewController:self didSignupUser:user];
            NSLog(@"User signed up and logged in with Twitter!");
        } else {
            NSLog(@"User logged in with Twitter!");
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
    hud.labelText = [NSString lm_parseError:error];
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
