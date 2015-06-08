#import "AppDelegate.h"
#import "ForumTableViewController.h"
#import "AppConstant.h"
#import "LMCurrentUserProfileViewController.h"
#import "OnlineUsersViewController.h"
#import "LMSettingsViewController.h"

#import <Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

NSString *const kTwitterConsumerKey = @"9oOsW4QAd5Gnj4LXICYK3uLAu";
NSString *const kTwitterConsumerSecret = @"t11OthB0Q0jBRYGL28UqmEsnyNtHAAMw6uc6rAt2GkXovTLj8l";

@interface AppDelegate ()

@property (strong, nonatomic) UITabBarController *tab;
@property (strong, nonatomic) UINavigationController *nav;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    /* Enable Parse and Facebook Utilities */
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOption];
    [PFTwitterUtils initializeWithConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PFUser *currentUser = [PFUser currentUser];
    
    //For Remote Notifications when app is in background mode
    NSDictionary *notificationPayload = launchOption[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload) {
        [self application:application receivedNotificationWithPayload:notificationPayload fetchCompletionHandler:nil];
    }
    
    if (currentUser) {
        [self presentHomeScreen];
    } else {
        [self presentSignupWalkthrough];
    }
    
    [self registerForUserLoginNotification];
    [self registerForUserLogoutNotification];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Notification Center

-(void) registerForUserLoginNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_USER_LOGGED_IN object:nil queue:nil usingBlock:^(NSNotification *note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentHomeScreen];
        });
    }];
}

-(void) registerForUserLogoutNotification
{
    // User needs to be notified that they will be deleted from Langue Match
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_USER_LOGGED_OUT object:nil queue:nil usingBlock:^(NSNotification *note) {
        [PFUser logOut];
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation removeObjectForKey:PF_INSTALLATION_USER];
        [installation saveEventually];
        [PFQuery clearAllCachedResults];
        self.tab = nil;
        self.nav = nil;
        [self presentSignupWalkthrough];
    }];
}

-(void) presentSignupWalkthrough
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    
    UIViewController *loginWalkthroughVC = [sb instantiateViewControllerWithIdentifier:@"LMLoginWalkthrough"];
    [self.nav setViewControllers:@[loginWalkthroughVC]];
    
    self.nav.navigationBarHidden = YES;
    self.window.rootViewController = self.nav;
}

-(void) presentHomeScreen
{
    self.nav = nil;
    
    ForumTableViewController *tableVC = [[ForumTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableVC.title = @"Forums";
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:tableVC];
    
    OnlineUsersViewController *onlineVC = [[OnlineUsersViewController alloc] initWithStyle:UITableViewStyleGrouped];
    onlineVC.title = @"Online";
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:onlineVC];
    
    LMCurrentUserProfileViewController *profileVC = [[LMCurrentUserProfileViewController alloc] initWithUser:[PFUser currentUser]];
    profileVC.title = @"Profile";
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    LMSettingsViewController *settingsVC = [[LMSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsVC.title = @"Settings";
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    self.tab = [[UITabBarController alloc] init];
    [self.tab setViewControllers:@[nav1, nav2, nav3, nav4] animated:YES];
    
    self.window.rootViewController = self.tab;
}

#pragma mark - Application Life Cycle

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [PFUser logOut];
}


#pragma mark - Facebook Utilities

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}


#pragma mark - Push Notification Methods

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData: deviceToken];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"failed to register for remote notifications");
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self application:application receivedNotificationWithPayload:userInfo fetchCompletionHandler:completionHandler];
}

#pragma mark - Helper Method

-(void) application:(UIApplication *)application receivedNotificationWithPayload:(NSDictionary *)payload fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // No payloads - just notifications for new messages
    
    if (UIApplicationStateActive == [[UIApplication sharedApplication] applicationState])
    {
        NSInteger newBadgeNumber =- [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeNumber];
    };
    
}
@end
