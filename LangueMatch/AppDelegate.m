#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "LMLoginViewController.h"

//Temporary
#import "LMHomeScreenViewController.h"

NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //Temporary
    
    LMLoginViewController *loginVC = [[LMLoginViewController alloc] init];
    loginVC.title = @"Login";
     
    [PFUser logInWithUsernameInBackground:@"jeff" password:@"BrandNew6" block:^(PFUser *user, NSError *error) {
        if (!error) {
            NSLog(@"Logged in with %@", user.username);
        } else {
            //ToDo error Handling
        }
    }];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    UINavigationController *nav = [UINavigationController new];
    LMHomeScreenViewController *homeVC = [[LMHomeScreenViewController alloc] init];
    [nav setViewControllers:@[homeVC]];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
