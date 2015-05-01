#import "AppDelegate.h"
#import "AppConstant.h"

#import "LMLoginViewController.h"
#import "LMFriendsListViewController.h"
#import "LMContactListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"

#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

@interface AppDelegate ()

@property (strong, nonatomic) UINavigationController *nav;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    
    /* Enable Parse and Facebook Utilities */
    [Parse enableLocalDatastore];
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOption];
    
    PFUser *currentUser = [PFUser currentUser];
    [PFUser enableRevocableSessionInBackground];
    
    //For Remote Notifications when app is in background mode
    NSDictionary *notificationPayload = launchOption[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload) {
        [self application:application receivedNotificationWithPayload:notificationPayload fetchCompletionHandler:nil];
    }
    
    /* Check if user data is cached on disk, if so present home screen */
    if (currentUser) {
        [self presentHomeScreen];
    } else {
        [self presentLoginWalkthrough];
    }
    
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
//    [application registerUserNotificationSettings:settings];
//    [application registerForRemoteNotifications];
    
    [self registerForUserLoginNotification];
    [self registerForUserLogoutNotification];
    
    return YES;
}

#pragma mark - Notification Center

-(void) registerForUserLoginNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_USER_LOGGED_IN object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
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
        [installation removeObjectForKey: PF_INSTALLATION_USER];
        [installation saveEventually:^(BOOL succeeded, NSError *error) {
            if (error)
            {
                NSLog(@"Error signing out push");
            }
        }];
        
//        [PFObject unpinAllObjectsInBackground];
        [PFQuery clearAllCachedResults];
        self.nav = nil;
        [self presentLoginScreen];
    }];
}

-(void) presentHomeScreen
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    LMFriendsListViewController *friendsListVC = [[LMFriendsListViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:friendsListVC];
    
    LMContactListViewController *contactListVC = [[LMContactListViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:contactListVC];
    
    LMChatsListViewController *chatsListVC = [[LMChatsListViewController alloc] init];
    chatsListVC.title = @"Chats";
     UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:chatsListVC];
    
    LMUserProfileViewController *profileVC = [[LMUserProfileViewController alloc] initWith:[PFUser currentUser]];
    profileVC.title = @"My Profile";
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    [tabBarController setViewControllers:@[nav1, nav2, nav3, nav4] animated:YES];
    
    self.window.rootViewController = tabBarController;
    
    if (_nav) {
        _nav = nil;
    }
    
    [self configureViewControllerForWindow];
}

-(void) presentLoginScreen
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    LMLoginViewController *loginVC = [[LMLoginViewController alloc] init];
    loginVC.title = @"Login";
    [self.nav setViewControllers:@[loginVC]];
    
    self.window.rootViewController = _nav;
    [self configureViewControllerForWindow];
}

-(void) presentLoginWalkthrough
{
    if (!self.nav) {
        self.nav = [UINavigationController new];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    
    UIViewController *loginWalkthroughVC = [sb instantiateViewControllerWithIdentifier:@"LMLoginWalkthrough"];
    [self.nav setViewControllers:@[loginWalkthroughVC]];
    
    self.nav.navigationBarHidden = YES;
    self.window.rootViewController = _nav;
    [self configureViewControllerForWindow];
}

-(void) configureViewControllerForWindow
{
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
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

//    Use code for handling UI updates when in background
//            if (application.applicationState == UIApplicationStateInactive)
//            {
//                NSLog(@"Inactive");
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:message];
//                completionHandler(UIBackgroundFetchResultNewData);
//            }
//            else if (application.applicationState == UIApplicationStateBackground)
//            {
//                NSLog(@"Background");
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:message];
//                completionHandler(UIBackgroundFetchResultNewData);
//            }
//            else if (application.applicationState == UIApplicationStateActive)
//            {
//                NSLog(@"Active");
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:message];
//                completionHandler(UIBackgroundFetchResultNewData);
//            }
//        } else {
            //Needed if user deletes local chat
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_CHAT object:groupId];
//            completionHandler(UIBackgroundFetchResultNoData);


}

#pragma mark - Helper Method

-(void) application:(UIApplication *)application receivedNotificationWithPayload:(NSDictionary *)payload fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString *messageId = [payload objectForKey:PF_MESSAGE_ID];
    
    if (UIApplicationStateActive == [[UIApplication sharedApplication] applicationState])
    {
        NSInteger newBadgeNumber =- [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeNumber];
    };
    
    PFQuery *messageQuery = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
    [messageQuery includeKey:PF_CHAT_CLASS_NAME];
    [messageQuery getObjectInBackgroundWithId:messageId block:^(PFObject *message, NSError *error){
        if (error)
        {
            completionHandler(UIBackgroundFetchResultFailed);
        }
        else if (message) {
            
//            PFObject *chat = [message objectForKey:PF_CHAT_CLASS_NAME];
//            [chat pinInBackground];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:message];
            
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultNewData);
            }
        }
    }];
}
@end
