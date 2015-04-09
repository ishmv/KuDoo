#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "LMUsers.h"
#import "AppConstant.h"
#import "LMData.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface LMSignUpViewController () <LMSignUpViewDelegate>

@property (strong, nonatomic) LMSignUpView *signUpView;

@end

@implementation LMSignUpViewController

-(instancetype)init
{
    if (self = [super init]){
    }
    return self;
}

static NSArray *languages;

+(void)load
{
    languages = @[@"English", @"Spanish", @"Japanese", @"Hindi"];
}

#pragma mark - View Controller Lifecycle

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.signUpView = [[LMSignUpView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height)];
    self.signUpView.delegate = self;
    
    for (UIView *view in @[self.signUpView]) {
        [self.view addSubview:view];
    }
}


#pragma mark - LMSignUpView Delegate
-(void)PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button
{
    [SVProgressHUD show];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome to LanguageMatch! Signing In", @"Welcome to LanguageMatch! Signing In") maskType:SVProgressHUDMaskTypeClear];
             [self postUserSignedInNotification];
             
             ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                 if (granted)
                 {
                     [[LMData sharedInstance] searchContactsForLangueMatchUsers];
                 }
                 else
                 {
                     NSLog(@"C'mon man!!");
                 }
             });
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 [[LMUsers sharedInstance] saveUserProfileImage:[UIImage imageNamed:@"empty_profile.png"]];
                 PFInstallation *installation = [PFInstallation currentInstallation];
                 installation[PF_INSTALLATION_USER] = [PFUser currentUser];
                 [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (error)
                     {
                         NSLog(@"Error registering for push notifications");
                     }
                 }];
             });
             
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         
         else
         {
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(error.description, error.description) maskType:SVProgressHUDMaskTypeClear];
         }
         
     }];
}

-(void) userSignedUpWithFacebookAccount
{
    [self postUserSignedInNotification];
}

#pragma mark - LMSignUpViewController Delegate

-(void)pressedFluentLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion
{
    [self presentLanguageOptionsWithCompletionHandler:completion];
}

-(void)pressedDesiredLanguageButton:(UIButton *)sender withCompletion:(LMCompletedSelectingLanguage)completion
{
    [self presentLanguageOptionsWithCompletionHandler:completion];
}

-(void) presentLanguageOptionsWithCompletionHandler:(LMCompletedSelectingLanguage)completion
{
    UIAlertController *languageSelectorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose your native language", @"Choose native language")
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableArray *actions = [NSMutableArray new];
    
    for (NSString *language in languages) {
        UIAlertAction *languageOption = [UIAlertAction actionWithTitle:language style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completion(language);
        }];
        
        [actions addObject:languageOption];
    }
    
    for (UIAlertAction *alert in actions) {
        [languageSelectorAlert addAction:alert];
    }
    
    [self presentViewController:languageSelectorAlert animated:YES completion:nil];
}

#pragma mark - Notification Center

-(void) postUserSignedInNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
