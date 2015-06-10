//
//  LMSettingsViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSettingsViewController.h"
#import "AppConstant.h"
#import "ParseConnection.h"

#import <PFUser.h>

@interface LMSettingsViewController ()

@property (nonatomic, assign) BOOL online;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    NSString *textLabel;
    NSString *detailTextLabel;
    
    switch (indexPath.section) {
        case 0:
            textLabel = @"NOTIFICATIONS";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    textLabel = @"ONLINE";
                    detailTextLabel = @"Appear online (available for chat)";
                    
                    UISwitch *toggleSwitch = [[UISwitch alloc] init];
                    [toggleSwitch addTarget:self action:@selector(toggleOnline:) forControlEvents:UIControlEventValueChanged];
                    [toggleSwitch setOn:_online];
                    cell.accessoryView = [[UIView alloc] initWithFrame:toggleSwitch.frame];
                    [cell.accessoryView addSubview:toggleSwitch];
                }
                    break;
                case 1:
                    textLabel = @"LOGOUT";
                    detailTextLabel = @"Go offline";
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
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil];
            break;
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
            return @"Status";
        default:
            break;
    }
    return @"";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Touch Handling

-(void) toggleOnline:(UISwitch *)toggle
{
    [ParseConnection setUserOnlineStatus:toggle.on];
    self.online = toggle.on;
}

@end
