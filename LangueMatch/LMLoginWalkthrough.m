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
@property (weak, nonatomic) IBOutlet UILabel *slogan;

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
    [self.view bringSubviewToFront:self.slogan];
    
    [[self.registerButton layer] setCornerRadius:5.0f];
    [[self.registerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self.registerButton layer] setBorderWidth:1.0f];
    
    [[self.loginButton layer] setCornerRadius:5.0f];
    [[self.loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self.loginButton layer] setBorderWidth:1.0f];
    
    [self.pageViewController didMoveToParentViewController:self];
}

static NSArray *pictures;
static NSArray *titles;

-(void) loadMedia
{
    pictures = @[@"personTyping", @"city", @"sunrise", @"country"];
    titles =  @[NSLocalizedString(@"Converse with native speakers around the world", @"Promotion 1"), NSLocalizedString(@"Customize your language profile", @"Promotion 2"), NSLocalizedString(@"Search for other language learners", @"Promotion 3"), NSLocalizedString(@"And Connect through realtime chat", @"Promotion 4")];
}

-(void)dealloc
{
    pictures = nil;
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
    UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Language Selected", @"No Language Selected") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", "OK") otherButtonTitles: nil];
    
    self.nativeLanguagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx1) {
        if (idx1 != 0) {
            
            [ParseConnection saveUserLanguageSelection:idx1 forType:LMLanguageSelectionTypeFluent1];
            self.nativeLanguageIndex = idx1;
            
            self.desiredLanguagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx2) {
                
                if (idx2 == 0) {
                    [noSelectionAlert show];
                }
                
                else if (idx2 == _nativeLanguageIndex) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Language Already Chosen", @"Language Already Chosen") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", "OK") otherButtonTitles: nil];
                    [alert show];
                    
                } else {
                    
                    [ParseConnection saveUserLanguageSelection:idx2 forType:LMLanguageSelectionTypeDesired];
                    LMSignUpProfileView *profileVC = [[LMSignUpProfileView alloc] initWithUser:[PFUser currentUser]];
                    profileVC.title = NSLocalizedString(@"Profile", @"Profile");
                    [self.nav pushViewController:profileVC animated:YES];
                }
            }];
            
            self.desiredLanguagePicker.title = NSLocalizedString(@"Language Picker", @"Language Picker");
            self.desiredLanguagePicker.pickerTitle = NSLocalizedString(@"Select Learning Language", @"Select Learning Language");
            [self.nav pushViewController:_desiredLanguagePicker animated:YES];
            
        } else {
            
            [noSelectionAlert show];
        }
    }];
    
    self.nativeLanguagePicker.title = NSLocalizedString(@"Welcome to KuDoo!", @"Welcome Banner");
    self.nativeLanguagePicker.buttonTitle = NSLocalizedString(@"Select Learning Language", @"Select Learning Language");
    self.nativeLanguagePicker.pickerTitle = NSLocalizedString(@"Select Native Language", @"Select Native Language");
    [self.nav setNavigationBarHidden:NO];
    [self.nav.navigationItem setBackBarButtonItem:nil];
    
    [self.nav setViewControllers:@[self.nativeLanguagePicker] animated:YES];
}

@end
