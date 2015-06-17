#import "LMSettingsViewController.h"
#import "AppConstant.h"
#import "ParseConnection.h"
#import "UIColor+applicationColors.h"
#import "LMImageSelector.h"
#import "NSArray+LanguageOptions.h"

#import <PFUser.h>

@interface LMSettingsViewController ()

@property (nonatomic, assign) BOOL isRegisteredForNotifications;
@property (nonatomic, assign) BOOL online;

@property (strong, nonatomic) UISwitch *onlineSwitch;
@property (strong, nonatomic) UISwitch *notificationSwitch;
@property (strong, nonatomic) LMImageSelector *imageSelector;

@end

@implementation LMSettingsViewController

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"settings"] tag:1];
        
        PFUser *currentUser = [PFUser currentUser];
        self.online = [currentUser[PF_USER_ONLINE] boolValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    self.isRegisteredForNotifications = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    NSString *textLabel;
    NSString *detailTextLabel;
    
    switch (indexPath.section) {
        case 0:
            textLabel = NSLocalizedString(@"ALLOW", @"ALLOW");
            
            self.notificationSwitch = [[UISwitch alloc] init];
            [self.notificationSwitch addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
            [self.notificationSwitch setOn:_isRegisteredForNotifications];
            cell.accessoryView = [[UIView alloc] initWithFrame:self.notificationSwitch.frame];
            [cell.accessoryView addSubview:self.notificationSwitch];
            
            break;
        case 1:
            textLabel = NSLocalizedString(@"CUSTOMIZE", @"CUSTOMIZE");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                {
                    textLabel = NSLocalizedString(@"ONLINE", @"ONLINE");
                    
                    self.onlineSwitch = [[UISwitch alloc] init];
                    [self.onlineSwitch addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
                    [self.onlineSwitch setOn:_online];
                    cell.accessoryView = [[UIView alloc] initWithFrame:self.onlineSwitch.frame];
                    [cell.accessoryView addSubview:self.onlineSwitch];
                }
                    break;
                case 1:
                    textLabel = NSLocalizedString(@"LOGOUT", @"LOGOUT");
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    [cell.textLabel setText:textLabel];
    cell.detailTextLabel.text = detailTextLabel;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            if (!_imageSelector) {
                self.imageSelector = [[LMImageSelector alloc] initWithImages:[NSArray lm_chatBackgroundImages]];
            }
            self.imageSelector.title = NSLocalizedString(@"Wallpapers", @"Wallpapers");
            [self.navigationController pushViewController:self.imageSelector animated:YES];
            break;
        case 2:
        {
            UIAlertController *signoutAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"Warning") message:NSLocalizedString(@"Signing out will delete all personal chats", @"Sign out warning") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *signoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Signout", @"Signout") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil];
            }];
            
            for (UIAlertAction *action in @[cancelAction, signoutAction]) {
                [signoutAlert addAction:action];
            }
            
            [self presentViewController:signoutAlert animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Notifications";
            break;
        case 1:
            return @"Chat Wallpaper";
            break;
        case 2:
            return @"Status";
        default:
            break;
    }
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSLocalizedString(@"Get notified of new messages. Only used for private chats.", @"Notification usage message") uppercaseString];
            break;
        case 2:
            return [NSLocalizedString(@"Warning: Signing out will delete all personal chats", @"Sign out warning") uppercaseString];
            break;
        default:
            break;
    }
    return @"";
}


#pragma mark - Touch Handling

-(void) toggleSwitch:(UISwitch *)toggle
{
    if (toggle == self.notificationSwitch) {
        if (toggle.on) {

            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
        } else {
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        }
    }
    
    if (toggle == self.onlineSwitch) {
        [ParseConnection setUserOnlineStatus:toggle.on];
        self.online = toggle.on;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        if (toggle.on) {
            alert.title = NSLocalizedString(@"ONLINE", @"ONLINE");
            alert.message = NSLocalizedString(@"You are visible to user searches", @"Online Message");
        } else {
            alert.title = NSLocalizedString(@"ONLINE", @"ONLINE");
            alert.message = NSLocalizedString(@"You are invisible to user searches", @"Offline Message");
        }
        
        [alert show];
    }
}

@end
