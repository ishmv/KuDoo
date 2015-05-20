#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"
#import "LMParseConnection.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD/SVProgressHUD.h>
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

-(void)PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button
{
    [SVProgressHUD showWithStatus:@"SIGNING UP"];
    
    [LMParseConnection signupUser:user withCompletion:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             NSString *errorMessage = [LMGlobalVariables parseError:error];
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         else if (succeeded)
         {
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome to LangueMatch!", @"Welcome to LangueMatch!") maskType:SVProgressHUDMaskTypeClear];
             [self firstTimeLoginSetup];
         }
         
     }];
}


-(void) userPressedFacebookButtonWithLanguagePreferences:(NSDictionary *)preferences
{
    NSString *desiredLanguage = preferences[PF_USER_DESIRED_LANGUAGE];
    NSString *fluentLanguage = preferences[PF_USER_FLUENT_LANGUAGE];
    
    if ([fluentLanguage containsString:@"language"] || [desiredLanguage containsString:@"language"])
    {
        UIAlertController *selectLanguageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please Select Language Preferences", @"Select language preferences")
                                                                                     message:NSLocalizedString(@"Select your language preferences before signing in with Facebook", "Select Language")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Got It." style:UIAlertActionStyleCancel handler:nil];
        
        [selectLanguageAlert addAction:cancelAction];
        [self presentViewController:selectLanguageAlert animated:YES completion:nil];
    }
    else
    {
        NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
        
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            if (error)
            {
                NSString *errorMessage = [LMGlobalVariables parseError:error];
                [SVProgressHUD showErrorWithStatus:errorMessage];
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
                                user[PF_USER_FLUENT_LANGUAGE] = fluentLanguage;
                                user[PF_USER_DESIRED_LANGUAGE] = desiredLanguage;
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
                    [self firstTimeLoginSetup];
                } else {
                    NSLog(@"User with facebook logged in!");
                    [self p_postUserSignedInNotification];
                }
            }
        }];
    }
}

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
    UIAlertController *languageSelectorAlert =   [LMAlertControllers chooseLanguageAlertWithCompletionHandler:^(NSInteger language) {
        NSString *languageChoice = [LMGlobalVariables LMLanguageOptions][language];
        completion(languageChoice);
    }];
    
    [self presentViewController:languageSelectorAlert animated:YES completion:nil];
}

-(void) profileImageViewSelected:(UIImageView *)imageView
{
    UIAlertController *cameraSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger selection) {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = selection;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraSourceTypeAlert animated:YES completion:nil];
}

-(void) hasAccountButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Notification Center

-(void) p_postUserSignedInNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

#pragma mark - First Time Login

/* 
 
 If user allows LM to access phonebook will compare contacts against LM database
 Will add matches to users friend list array
 
*/

-(void) firstTimeLoginSetup
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[PF_INSTALLATION_USER] = [PFUser currentUser];
        [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error registering Device");
             }
         }];
    });
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted)
        {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading Contacts", @"Loading Contacts") maskType:SVProgressHUDMaskTypeClear];
            
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex peopleCount = ABAddressBookGetPersonCount(addressBook);
            
            NSMutableArray *emailList = [NSMutableArray new];
            
            for (int i = 0; i < peopleCount; i++) {
                
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                
                ABMultiValueRef emailRef = ABRecordCopyValue(person, kABPersonEmailProperty);
                
                for (int i = 0; i < ABMultiValueGetCount(emailRef); i++) {
                    CFStringRef currenEmailLabel = ABMultiValueCopyLabelAtIndex(emailRef, i);
                    CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailRef, i);
                    
                    if (CFStringCompare(currenEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                        [emailList addObject:(__bridge NSString *)currentEmailValue];
                    }
                    
                    if (CFStringCompare(currenEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                        [emailList addObject:(__bridge NSString *)currentEmailValue];
                    }
                    
                    CFRelease(currenEmailLabel);
                    CFRelease(currentEmailValue);
                }
                
                CFRelease(emailRef);
                
            }
            
            CFRelease(addressBook);
            
            
            NSSet *setWithNoDuplicateEmails = [NSSet setWithArray:emailList];
            NSMutableArray *arrayWithNoDuplicats = [NSMutableArray array];
            
            for (NSString *email in setWithNoDuplicateEmails) {
                [arrayWithNoDuplicats addObject:email];
            }
        
            [self searchContacts:arrayWithNoDuplicats];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Address Book Admission Declined", @"Address Book Admission Declined") maskType:SVProgressHUDMaskTypeClear];
            [self p_postUserSignedInNotification];
        }
    });
}

- (void)searchContacts: (NSArray *)contacts
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_EMAIL containedIn:contacts];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error) {
            
            PFUser *currentUser = [PFUser currentUser];
            NSMutableArray *friendsWithoutCurrentUser = [friends mutableCopy];
            if ([friendsWithoutCurrentUser containsObject:currentUser]) [friendsWithoutCurrentUser removeObject:currentUser];
            
            [PFObject pinAllInBackground:friendsWithoutCurrentUser withName:PF_USER_FRIENDSHIPS];
            
            PFRelation *relation = [currentUser relationForKey:PF_USER_FRIENDSHIPS];
            
            for (PFUser *user in friends)
            {
                [relation addObject:user];
                [currentUser saveInBackground];
            }
            
            [self registerForRemoteNotifications];
            
        }
        else if (error)
        {
            [SVProgressHUD showErrorWithStatus:[LMGlobalVariables parseError:error]];
        }
    }];
}

-(void) registerForRemoteNotifications
{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [SVProgressHUD dismiss];

    [self p_postUserSignedInNotification];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.signUpView.profileImage = editedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
