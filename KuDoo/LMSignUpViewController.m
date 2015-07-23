#import "LMSignUpViewController.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "NSString+Chats.h"
#import "ParseConnection.h"
#import "UIButton+TapAnimation.h"
#import "UIFont+ApplicationFonts.h"
#import "LMSignUpView.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface LMSignUpViewController () <LMSignUpViewDelegate>

@end

@implementation LMSignUpViewController

#pragma mark - View Controller Lifecycle

-(instancetype)init
{
    if (self = [super init]){
        _signUpView = ({
            LMSignUpView *signupView = [[LMSignUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            signupView.delegate = self;
            signupView;
        });
        
        for (UIView *view in @[_signUpView]) {
            [self.view addSubview:view];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - LMSignUpView Delegate

-(void) userWithCredentials:(NSDictionary *)info pressedSignUpButton:(UIButton *)sender
{
    PFUser *user = ({
        PFUser *user = [PFUser user];
        user.username = info[PF_USER_USERNAME];
        user.password = info[PF_USER_PASSWORD];
        user.email = info[PF_USER_EMAIL];
        user[PF_USER_DISPLAYNAME] = info[PF_USER_DISPLAYNAME];
        user;
    });
    
    [ParseConnection signupUser:user withCompletion:^(BOOL succeeded, NSError *error){
         if (error != nil) {
             [self p_showHUDWithError:error];
         } else if (succeeded){
             [self.delegate signupViewController:self didSignupUser:user withSocialMedia:socialMediaNone];
         }
     }];
}


-(void) facebookButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (error) {
            [self p_showHUDWithError:error];
        }
        else {
            if (user.isNew) {
                
                [self p_showHUDSettingUpAccount];
                
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
                            user.username = [fullName lowercaseString];
                            user[PF_USER_DISPLAYNAME] = fullName;
                            user[PF_USER_EMAILCOPY] = [email lowercaseString];
                            user[PF_USER_ONLINE] = @(YES);
                            [user saveInBackground];
                            
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            
                            [self.delegate signupViewController:self didSignupUser:user withSocialMedia:socialMediaFacebook];
                        }
                    }];
                }
            } else {
                [self.delegate signupViewController:self didLoginUser:user withSocialMedia:socialMediaFacebook];
            }
        }
    }];
    
}

-(void) twitterButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        
        if (error != nil) {
            [self p_showHUDWithError:error];
        }
        
        if (!user) {
            NSLog(@"The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            
            [self p_showHUDSettingUpAccount];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                NSString *username = [[PFTwitterUtils twitter] screenName];

                NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", username];
                NSURL *url = [NSURL URLWithString:requestString];
                
                NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:url];
                [[PFTwitterUtils twitter] signRequest:twitterRequest];
                
                NSURLResponse *response;
                NSError *error;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:twitterRequest returningResponse:&response error:&error];
                
                NSError *jsonError;
                NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                
                if (feedDictionary) {
                    
                    NSString *pictureString = [feedDictionary objectForKey:@"profile_image_url_https"];
                    NSString *resizedPicture = [pictureString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                    NSURL *pictureURL = [NSURL URLWithString:resizedPicture];
                    NSURLRequest *pictureRequest = [NSURLRequest requestWithURL:pictureURL];
                    
                    [NSURLConnection sendAsynchronousRequest:pictureRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (error != nil) {
                            NSLog(@"error retreiving profile picture");
                        }
                        
                        UIImage *profileImage = [UIImage imageWithData:data];
                        [ParseConnection saveUserImage:profileImage forType:LMUserPictureSelf];
                    }];

                    NSString *backgroundPictureString = [feedDictionary objectForKey:@"profile_background_image_url_https"];
                    NSURL *backgroundPictureURL = [NSURL URLWithString:backgroundPictureString];
                    NSURLRequest *backgroundPictureRequest = [NSURLRequest requestWithURL:backgroundPictureURL];

                    [NSURLConnection sendAsynchronousRequest:backgroundPictureRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        UIImage *backgroundImage = [UIImage imageWithData:data];
                        [ParseConnection saveUserImage:backgroundImage forType:LMUserPictureBackground];
                    }];
                    
                    [ParseConnection saveUsersUsername:username];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.delegate signupViewController:self didSignupUser:user withSocialMedia:socialMediaTwitter];
                }
            });
            
        } else {
            [self.delegate signupViewController:self didLoginUser:user withSocialMedia:socialMediaTwitter];
        }
    }];
}


-(void) existingAccountButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private Methods

-(void) p_showHUDWithError:(NSError *)error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.detailsLabelText = [NSString lm_parseError:error];
    hud.detailsLabelFont = [UIFont lm_robotoLightMessagePreview];
    
    hud.labelText = NSLocalizedString(@"Error", @"error");
    hud.labelFont = [UIFont lm_robotoRegularLarge];
    
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:2.0];
}

-(void) p_showHUDSettingUpAccount
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.detailsLabelText = NSLocalizedString(@"Welcome! Setting up KuDoo Account", @"setting up account");
    hud.labelFont = [UIFont lm_robotoRegular];
    
    hud.mode = MBProgressHUDModeAnnularDeterminate;
}

#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end