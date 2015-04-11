#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "LMUsers.h"
#import "AppConstant.h"
#import "LMData.h"
#import "LMContacts.h"
#import "LMPerson.h"

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
             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Welcome to LanguageMatch!", @"Welcome to LanguageMatch!") maskType:SVProgressHUDMaskTypeClear];
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 
                 [[LMUsers sharedInstance] saveUserProfileImage:[UIImage imageNamed:@"empty_profile.png"]];
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

-(void) firstTimeLoginSetup
{
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted)
        {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Loading Contacts", @"Loading Contacts") maskType:SVProgressHUDMaskTypeClear];
            
            LMContacts *contacts = [[LMContacts alloc] init];
            
            NSMutableArray *emailList = [NSMutableArray new];
            
            
            NSMutableArray *allContacts = [NSMutableArray arrayWithArray:[contacts.phoneBookContacts copy]];
            [allContacts addObjectsFromArray:[contacts.facebookContacts copy]];
            
            contacts = nil;
            /* -- Get rid of any duplicate persons --*/
            
            for (LMPerson *person in allContacts)
            {
                if ([person.homeEmail length] != 0) {
                    [emailList addObject:person.homeEmail];
                }
                
                if ([person.workEmail length] != 0) {
                    [emailList addObject:person.workEmail];
                }
            }
            
            /* -- Get rid of any duplicate persons --*/
            
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
            
            [PFObject pinAllInBackground:friends];
            PFUser *currentUser = [PFUser currentUser];
            [currentUser addUniqueObjectsFromArray:friends forKey:PF_USER_FRIENDS];
            [currentUser saveEventually];
            
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
