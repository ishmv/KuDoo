#import "AppDelegate.h"
#import "LMLoginViewController.h"
#import "LMData.h"
#import "AppConstant.h"
#import "ChatView.h"

#import "LMFriendsListViewController.h"
#import "LMContactListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"

#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

@interface AppDelegate ()

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
    
    /* Check if user data is cached on disk, if so present home screen */
    if (currentUser) {
        [self presentHomeScreen];
    } else {
        [self presentLoginScreen];
    }

    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [self registerForUserLoginNotification];
    [self registerForUserLogoutNotification];
    
    return YES;
}

#pragma mark - Notification Center

-(void) registerForUserLoginNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_USER_LOGGED_IN object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self presentHomeScreen];
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
        
        [PFObject unpinAllObjectsInBackground];
        [PFQuery clearAllCachedResults];
        self.nav = nil;
        [self presentLoginScreen];
    }];
}

-(void) presentHomeScreen
{
    if (_nav) {
        _nav = nil;
    }
    
    [LMData sharedInstance];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    LMFriendsListViewController *friendsListVC = [[LMFriendsListViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:friendsListVC];
    
    LMContactListViewController *contactListVC = [[LMContactListViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:contactListVC];
    
    LMChatsListViewController *chatsListVC = [[LMChatsListViewController alloc] init];
     UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:chatsListVC];
    
    LMUserProfileViewController *profileVC = [[LMUserProfileViewController alloc] init];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    [tabBarController setViewControllers:@[nav1, nav2, nav3, nav4] animated:YES];
    
    self.window.rootViewController = tabBarController;
    
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

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString *chatId = [userInfo objectForKey:PF_CHAT_GROUPID];
    
    PFQuery *getChat = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [getChat whereKey:PF_CHAT_GROUPID equalTo:chatId];
    [getChat whereKey:PF_CHAT_SENDER equalTo:[PFUser currentUser]];
    
    [getChat getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        if (chat) {
            ChatView *newChat = [[ChatView alloc] initWithChat:chat];
            [self.nav pushViewController:newChat animated:YES];
        } else {
            NSLog(@"Error Retreiving chat");
        }
        
        NSLog(@"Chat");
    }];
}
@end
