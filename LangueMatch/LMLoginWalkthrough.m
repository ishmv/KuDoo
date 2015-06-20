#import "LMLoginWalkthrough.h"
#import "AppConstant.h"
#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "ParseConnection.h"
#import "NSArray+LanguageOptions.h"
#import "LMLanguagePicker.h"
#import "LMSignUpProfileView.h"

@import CoreLocation;

@interface LMLoginWalkthrough () <UIPageViewControllerDataSource, LMLoginViewControllerDelegate, LMSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *langueMatchLabel;
@property (strong, nonatomic) NSArray *picturesArray;

@property (strong, nonatomic) LMLanguagePicker *nativeLanguagePicker;
@property (strong, nonatomic) LMLanguagePicker *desiredLanguagePicker;

@property (strong, nonatomic) UINavigationController *nav;

@property (nonatomic, assign) NSInteger nativeLanguageIndex;

@end

@implementation LMLoginWalkthrough

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadMedia];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [self.view bringSubviewToFront:self.registerButton];
    [self.view bringSubviewToFront:self.loginButton];
    [self.view bringSubviewToFront:self.langueMatchLabel];
    
    [[self.registerButton layer] setCornerRadius:5.0f];
    [[self.registerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self.registerButton layer] setBorderWidth:1.0f];
    
    [[self.loginButton layer] setCornerRadius:5.0f];
    [[self.loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self.loginButton layer] setBorderWidth:1.0f];
    
    [self.pageViewController didMoveToParentViewController:self];
}

static NSArray *pictures;
static NSArray *foregroundPictures;
static NSArray *titles;

-(void) loadMedia
{
    pictures = @[@"personTyping", @"city", @"sunrise", @"country", @"auroraBorealis"];
    foregroundPictures = @[@"onlineUsersPicture",@"ForumChatPic", @"exampleChat", @"profilePicture", @"SignupScreen"];
    titles =  @[NSLocalizedString(@"Converse with native speakers around the world", @"LangMatch Promotion 1"), NSLocalizedString(@"Connect through private and forum realtime chat", @"LangMatch Promotion 2"), NSLocalizedString(@"Use chat media to help others learn your native language", @"LangMatch Promotion 3"), NSLocalizedString(@"View and customize your profile", @"LangMatch Promotion 4"), NSLocalizedString(@"Signup with your existing Twitter or Facebook account", @"LangMatch Promotion 5")];
}

-(void)dealloc
{
    pictures = nil;
    foregroundPictures = nil;
    titles = nil;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    NSInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [titles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [titles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([titles count] == 0) || (index >= [titles count])) {
        return nil;
    }
    
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = pictures[index];
    pageContentViewController.foregroundImageFile = foregroundPictures[index];
    pageContentViewController.titleText = titles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Target/Action Methods
- (IBAction)registerButtonPressed:(UIButton *)sender
{
    [self setLoginAndSignUpViewControllersFrom:(UIButton *)sender];
}
- (IBAction)loginButtonPressed:(UIButton *)sender
{
    [self setLoginAndSignUpViewControllersFrom:nil];
}

-(void) setLoginAndSignUpViewControllersFrom:(UIButton *)sender
{
    LMLoginViewController *loginVC = [[LMLoginViewController alloc] init];
    loginVC.delegate = self;
    
    LMSignUpViewController *signUpVC = [[LMSignUpViewController alloc] init];
    signUpVC.delegate = self;
    
    loginVC.signUpVC = signUpVC;
    
    if (!_nav) self.nav = [[UINavigationController alloc] init];
    
    if (sender) {
        [self.nav setViewControllers:@[loginVC, signUpVC] animated:YES];
    } else {
        [self.nav setViewControllers:@[loginVC] animated:YES];
    }
    
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:self.nav];
}

#pragma mark - PFLoginViewController Delegate

-(void)loginViewController:(LMLoginViewController *)viewController didLoginUser:(PFUser *)user
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

-(void)signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user withSocialMedia:(socialMedia)social
{
    if (social == socialMediaNone) {
        [ParseConnection saveUserImage:[UIImage imageNamed:@"emptyProfile"] forType:LMUserPictureSelf];
        [ParseConnection saveUserImage:[UIImage imageNamed:@"miamiBeach"] forType:LMUserPictureBackground];
    } if (social == socialMediaFacebook) {
        [ParseConnection saveUserImage:[UIImage imageNamed:@"miamiBeach"] forType:LMUserPictureBackground];
    }
    
    [ParseConnection setUserOnlineStatus:YES];
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginWalkthrough];
}

-(void) presentLoginWalkthrough
{
    UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No language selected", @"No language selected") message:NSLocalizedString(@"Please make a selection", @"Please make a selection") delegate:nil cancelButtonTitle:@"Got It" otherButtonTitles: nil];
    
    self.nativeLanguagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx1) {
        if (idx1 != 0) {
            
            [ParseConnection saveUserLanguageSelection:idx1 forType:LMLanguageSelectionTypeFluent1];
            self.nativeLanguageIndex = idx1;
            
            self.desiredLanguagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx2) {
                
                if (idx2 == 0) {
                    [noSelectionAlert show];
                }
                
                else if (idx2 == _nativeLanguageIndex) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Select different language", @"Select different language") message:NSLocalizedString(@"You chose this as your native language", @"You chose this as your native language") delegate:nil cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                    [alert show];
                    
                } else {
                    
                    [ParseConnection saveUserLanguageSelection:idx2 forType:LMLanguageSelectionTypeDesired];
                    LMSignUpProfileView *profileVC = [[LMSignUpProfileView alloc] initWithUser:[PFUser currentUser]];
                    profileVC.title = NSLocalizedString(@"Profile", @"Profile");
                    [self.nav pushViewController:profileVC animated:YES];
                }
            }];
            
            self.desiredLanguagePicker.title = NSLocalizedString(@"Language Selection", @"Language Selection");
            self.desiredLanguagePicker.buttonTitle = NSLocalizedString(@"Customize Profile", @"Customize Profile");
            self.desiredLanguagePicker.pickerTitle = NSLocalizedString(@"Please select your learning language:", @"Please select your learning language:");
            [self.nav pushViewController:_desiredLanguagePicker animated:YES];
            
        } else {
            
            [noSelectionAlert show];
        }
    }];
    
    self.nativeLanguagePicker.title = NSLocalizedString(@"Welcome to LangMatch!", @"Welcome Banner");
    self.nativeLanguagePicker.buttonTitle = NSLocalizedString(@"Select Learning Language", @"Select Learning Language");
    self.nativeLanguagePicker.pickerTitle = NSLocalizedString(@"Please select your native language:", @"Select native language prompt");
    self.nativeLanguagePicker.pickerFooter = NSLocalizedString(@"Polyglot?\nYou will have the option to add more languages inside", @"Polygot note");
    [self.nav setNavigationBarHidden:NO];
    [self.nav.navigationItem setBackBarButtonItem:nil];
    
    [self.nav setViewControllers:@[self.nativeLanguagePicker] animated:YES];
}

@end
