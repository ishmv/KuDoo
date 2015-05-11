#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "LMUsers.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"

#import <PFFacebookUtils.h>
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

#pragma mark - View Controller Lifecycle

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
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome to LanguageMatch!", @"Welcome to LanguageMatch!") maskType:SVProgressHUDMaskTypeClear];
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 
                 [LMUsers saveUserProfileImage:[UIImage imageNamed:@"empty_profile.png"]];
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
             
             [self firstTimeLoginSetup];
         }
         
         else
         {
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(error.description, error.description) maskType:SVProgressHUDMaskTypeClear];
         }
         
     }];
}


-(void) userSignedUpWithFacebookAccount
{
    [self firstTimeLoginSetup];
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

#pragma mark - Notification Center

-(void) postUserSignedInNotification
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
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted)
        {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Loading Contacts", @"Loading Contacts") maskType:SVProgressHUDMaskTypeClear];
            
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
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"We won't be able to connect you with your friends!", @"We won't be able to connect you with your friends!") maskType:SVProgressHUDMaskTypeClear];
            
            [self postUserSignedInNotification];
        }
    });
}

- (void)searchContacts: (NSArray *)contacts
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_EMAIL containedIn:contacts];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error && friends != 0) {
            
            [PFObject pinAllInBackground:friends withName:PF_USER_FRIENDSHIPS];

            PFUser *currentUser = [PFUser currentUser];
            PFRelation *relation = [currentUser relationForKey:PF_USER_FRIENDSHIPS];
            
            for (PFUser *user in friends)
            {
                [relation addObject:user];
                [currentUser saveInBackground];
            }
            
            [self postUserSignedInNotification];
            
            [self dismissViewControllerAnimated:NO completion: nil];
            
        } else {
            NSLog(@"Error retreiving users");
        }
    }];
}

#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
