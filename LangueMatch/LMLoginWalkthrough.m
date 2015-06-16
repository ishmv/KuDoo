#import "LMLoginWalkthrough.h"
#import "AppConstant.h"
#import "LMLoginViewController.h"
#import "LMSignUpViewController.h"
#import "ParseConnection.h"

@import CoreLocation;

@interface LMLoginWalkthrough () <UIPageViewControllerDataSource, LMLoginViewControllerDelegate, LMSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *langueMatchLabel;
@property (strong, nonatomic) NSArray *picturesArray;

@property (strong, nonatomic) UINavigationController *nav;

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
    
    [[self.registerButton layer] setCornerRadius:10.0f];
    [[self.registerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[self.registerButton layer] setBorderWidth:1.0f];
    
    [[self.loginButton layer] setCornerRadius:10.0f];
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
    titles =  @[NSLocalizedString(@"Practice conversation by connecting with native speakers around the world", @"LangMatch Promotion 1"), NSLocalizedString(@"Connect through private and forum realtime chat", @"LangMatch Promotion 2"), NSLocalizedString(@"Use chat media to help others learn your native language", @"LangMatch Promotion 3"), NSLocalizedString(@"View and customize your profile to select people with similar interests", @"LangMatch Promotion 4"), NSLocalizedString(@"Sign up with your existing Twitter or Facebook account", @"LangMatch Promotion 5")];
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
    
//    [self.navigationController presentViewController:self.nav animated:YES completion:nil];
    
}

#pragma mark - PFLoginViewController Delegate

-(void)loginViewController:(LMLoginViewController *)viewController didLoginUser:(PFUser *)user
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self p_registerForRemoteNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

-(void)signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user withSocialMedia:(socialMedia)social
{
    if (social == socialMediaNone) {
        [ParseConnection saveUserImage:[UIImage imageNamed:@"empty_profile.png"] forType:LMUserPictureSelf];
        [ParseConnection saveUserImage:[UIImage imageNamed:@"miamiBeach.jpg"] forType:LMUserPictureBackground];
    } if (social == socialMediaFacebook) {
        [ParseConnection saveUserImage:[UIImage imageNamed:@"miamiBeach.jpg"] forType:LMUserPictureBackground];
    }
    
    [ParseConnection setUserOnlineStatus:YES];
    [self p_registerForRemoteNotifications];
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginWalkthrough];
}

-(void) presentLoginWalkthrough
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
    UIViewController *vc = (UIViewController *)[sb instantiateViewControllerWithIdentifier:@"LMLanguagePicker"];
    self.nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [[[UIApplication sharedApplication] delegate] window].rootViewController = self.nav;
}

-(void) p_registerForRemoteNotifications
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[PF_INSTALLATION_USER] = [PFUser currentUser];
    [installation saveInBackground];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end
