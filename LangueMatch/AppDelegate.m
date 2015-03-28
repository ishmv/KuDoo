#import "AppDelegate.h"
#import "LMLoginViewController.h"
#import "LMHomeScreenViewController.h"
#import "LMLoginWalkthrough.h"


@import Parse;
#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

@interface AppDelegate () <LMLoginViewControllerDelegate>

@property (strong, nonatomic) UINavigationController *nav;
@property (strong, nonatomic) UIViewController *walkthroughVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    
    /* Enable Parse and Facebook Utilities */
    [Parse enableLocalDatastore];
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    [PFFacebookUtils initializeFacebook];
    
    PFUser *currentUser = [PFUser currentUser];
    [PFUser enableRevocableSessionInBackground];
    
    /* Included for shipping */
    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
//    self.walkthroughVC = [sb instantiateViewControllerWithIdentifier:@"LMLoginWalkthrough"];
    
    
    /* Check if user data is cached on disk, if so present home screen */
    if (currentUser) {
        [self presentHomeScreen];
    } else {
        
        [self presentLoginScreen];
        
        //Move this to first time login/register
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted) {
                //ToDo Show Alert View - better experience inviting friends
            }
        });
        [self presentLoginScreen];
    }
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [self registerForUserLogoutNotification];
    [self configureViewControllerForWindow];
    
    return YES;
}

-(void) registerForUserLogoutNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LMUserDidLogoutNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [PFUser logOut];
        [PFObject unpinAllObjectsInBackground];
        [PFQuery clearAllCachedResults];
        self.nav = nil;
        [self presentLoginScreen];
    }];
}

-(void) presentHomeScreen
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    LMHomeScreenViewController *homeVC = [[LMHomeScreenViewController alloc] init];
    homeVC.title = @"Home";
    [self.nav setViewControllers:@[homeVC]];
    
    [self configureViewControllerForWindow];
}

-(void) presentLoginScreen
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    LMLoginViewController *loginVC = [[LMLoginViewController alloc] init];
    loginVC.delegate = self;
    loginVC.title = @"Login";
    [self.nav setViewControllers:@[loginVC]];
    
    [self configureViewControllerForWindow];
}

-(void) configureViewControllerForWindow
{
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.nav;
    [self.window makeKeyAndVisible];
}

#pragma mark - LMHomeScreen Delegate
-(void) userSuccessfullyLoggedIn
{
    [self presentHomeScreen];
}


#pragma mark - Application Life Cycle

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

#pragma mark - Facebook Utilities

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}


#pragma mark - Push Notification Methods

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData: deviceToken];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

@end
