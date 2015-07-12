#import "AppDelegate.h"
#import "ForumTableViewController.h"
#import "AppConstant.h"
#import "NSString+Chats.h"
#import "LMCurrentUserProfileView.h"
#import "OnlineUsersViewController.h"
#import "ChatsTableViewController.h"
#import "LMSettingsViewController.h"

#import <Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <JCNotificationBannerPresenter/JCNotificationCenter.h>
#import <JCNotificationBannerPresenter/JCNotificationBannerPresenterIOS7Style.h>

@import AudioToolbox;

NSString *const kFirebaseAddress = @"https://langMatch.firebaseio.com";

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

NSString *const kTwitterConsumerKey = @"9oOsW4QAd5Gnj4LXICYK3uLAu";
NSString *const kTwitterConsumerSecret = @"t11OthB0Q0jBRYGL28UqmEsnyNtHAAMw6uc6rAt2GkXovTLj8l";

@interface AppDelegate ()

@property (strong, nonatomic) UITabBarController *tab;
@property (strong, nonatomic) UINavigationController *nav;

@property (strong, nonatomic) ChatsTableViewController *chatsVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    /* Enable Parse and Facebook Utilities */
    [ParseCrashReporting enable];
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOption];
    [PFTwitterUtils initializeWithConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    
    [self p_loadUserDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser) {
        [self presentHomeScreen];
    } else {
        [self presentSignupWalkthrough];
    }
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self registerForUserLoginNotification];
    [self registerForUserLogoutNotification];
//    [self registerArchiveChatNotifications];

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
        [installation deleteEventually];
        [PFQuery clearAllCachedResults];
        self.tab = nil;
        self.nav = nil;
        [self p_deleteArchive];
        [self presentSignupWalkthrough];
    }];
}

//-(void) registerForArchiveChatNotifications
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_ARCHIVE_CHATS object:nil queue:nil usingBlock:^(NSNotification *note) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self p_archiveChats];
//        });
//    }];
//}

-(void) p_loadUserDefaults
{
    // Chat wallpaper background
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Chat_Wallpaper_Index"];
    if (data == NULL)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithInteger:2]];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"Chat_Wallpaper_Index"];
    }
    
    // Set all bar button item tint colors to white
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    }
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
    
    [self.window makeKeyAndVisible];
}

-(void) presentHomeScreen
{
    self.nav = nil;
    
    ForumTableViewController *tableVC = [[ForumTableViewController alloc] initWithFirebaseAddress:kFirebaseAddress];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:tableVC];
    
    OnlineUsersViewController *onlineVC = [[OnlineUsersViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:onlineVC];
    
    self.chatsVC = [self p_unarchiveChats];
    
    if (self.chatsVC == nil) {
        self.chatsVC = [[ChatsTableViewController alloc] initWithFirebaseAddress:kFirebaseAddress];
    }
    self.chatsVC.title = @"Chats";
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:self.chatsVC];
    
    LMCurrentUserProfileView *profileVC = [[LMCurrentUserProfileView alloc] initWithUser:[PFUser currentUser]];
    profileVC.title = @"Profile";
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    LMSettingsViewController *settingsVC = [[LMSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsVC.title = @"Settings";
    UINavigationController *nav5 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    self.tab = [[UITabBarController alloc] init];
    [self.tab setViewControllers:@[nav1, nav2, nav3, nav4, nav5] animated:YES];
    
    self.window.rootViewController = self.tab;
}

#pragma mark - Application Life Cycle

- (void)applicationWillResignActive:(UIApplication *)application {
    [self p_archiveChats];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self p_archiveChats];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [PFInstallation currentInstallation].badge = 0;
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [PFInstallation currentInstallation].badge = 0;
    [[PFInstallation currentInstallation] saveInBackground];
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self p_archiveChats];
}

#pragma mark - Keyed Archiving

-(ChatsTableViewController *) p_unarchiveChats
{
    NSString *archivePath = [NSString lm_pathForFilename:NSStringFromSelector(@selector(chatsVC))];
    ChatsTableViewController *chatVC = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    return chatVC;
}

-(void) p_archiveChats
{
    NSString *archivePath = [NSString lm_pathForFilename:NSStringFromSelector(@selector(chatsVC))];
    NSData *chatData = [NSKeyedArchiver archivedDataWithRootObject:self.chatsVC];
    
    NSError *dataError;
    BOOL wroteSuccessfully = [chatData writeToFile:archivePath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
    
    if (!wroteSuccessfully) {
        NSLog(@"Error saving chat data");
    }
}

-(void) p_deleteArchive
{
    NSString *archivePath = [NSString lm_pathForFilename:NSStringFromSelector(@selector(chatsVC))];
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
    if (!success) {
        NSLog(@"There was a problem delete the archived chats");
    }
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
    NSLog(@"Registered For Remote Notifications");
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"failed to register for remote notifications");
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.chatsVC != nil) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = self.chatsVC.newMessageCounter;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    NSString *groupId = userInfo[@"groupId"];
    
    switch (state) {
        case UIApplicationStateBackground:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:groupId];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            completionHandler(UIBackgroundFetchResultNewData);
            break;
        case UIApplicationStateActive:
        {
            if (self.tab.selectedIndex != 2) {
                NSDictionary *aps = [userInfo objectForKey:@"aps"];
                NSString *name = [aps objectForKey:@"alert"];
                NSString *alert = @"Tap to go to conversation >";
                [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOS7Style new];
                [JCNotificationCenter enqueueNotificationWithTitle:name message:alert tapHandler:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:groupId];
                    
                }];
            }
            
            completionHandler(UIBackgroundFetchResultNewData);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        }
        case UIApplicationStateInactive:
        default:
        {
            completionHandler(UIBackgroundFetchResultNewData);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:groupId];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        }
    }
}

@end
