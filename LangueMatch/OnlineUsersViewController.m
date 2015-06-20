//
//  TableViewController.m
//  friendChat
//
//  Created by Travis Buttaccio on 5/31/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "OnlineUsersViewController.h"
#import "AppConstant.h"
#import "LMTableViewCell.h"
#import "LMOnlineUserProfileViewController.h"
#import "UIColor+applicationColors.h"
#import "ParseConnection.h"
#import "LMUserViewModel.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface OnlineUsersViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSArray *onlineUsers;
@property (strong, nonatomic) NSMutableDictionary *userViewControllers;
@property (strong, nonatomic) NSMutableDictionary *userThumbnails;

@end

@implementation OnlineUsersViewController

static NSString *reuseIdentifier = @"reuseIdentifier";

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"online"]];
        self.tabBarItem.title = @"Online";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 8);
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.barTintColor = [UIColor lm_wetAsphaltColor];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search Username", @"Search Username");
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(p_fetchOnlineUsers)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    [self p_fetchOnlineUsers];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.onlineUsers = nil;
    self.userThumbnails = nil;
    self.userViewControllers = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.onlineUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = self.onlineUsers[indexPath.row];
    LMUserViewModel *viewModel = [[LMUserViewModel alloc] initWithUser:user];
    
    cell.cellImageView.image = self.userThumbnails[user.objectId];
    [cell.cellImageView.layer setMasksToBounds:YES];
    [cell.cellImageView.layer setCornerRadius:15.0f];
    [cell.cellImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.cellImageView.layer setBorderWidth:3.0f];
    
    
//    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    accessoryView.backgroundColor = [UIColor lm_tealColor];
//    [accessoryView.layer setCornerRadius:10.0f];
//    [accessoryView.layer setMasksToBounds:YES];
//    cell.accessoryView = accessoryView;
    
    cell.titleLabel.text = user[PF_USER_DISPLAYNAME];
    cell.detailLabel.text = [viewModel fluentLanguageString];
    cell.accessoryLabel.text = [viewModel locationString];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.searchController.active = NO;
    
    PFUser *user = self.onlineUsers[indexPath.row];
    
    LMOnlineUserProfileViewController *userVC;
    
    userVC = [self.userViewControllers objectForKey:user.objectId];
    
    if (!userVC) {
        userVC = [[LMOnlineUserProfileViewController alloc] initWithUser:user];
        userVC.profilePicView.image = self.userThumbnails[user.objectId];
        [self.userViewControllers setObject:userVC forKey:user.objectId];
    }
    
    [self.navigationController pushViewController:userVC animated:YES];
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 20)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

#pragma mark - Search Controller Delegate


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = [self.searchController.searchBar.text lowercaseString];
    
    [ParseConnection searchForUsername:searchText withCompletion:^(NSArray *users, NSError *error) {
        if (users.count == 0) {
            [self p_showStatusBarWithText:@"No users match that criteria"];
        } else {
            self.onlineUsers = [users mutableCopy];
            [self.tableView reloadData];
            [self p_showStatusBarWithText:[NSString stringWithFormat:@"%@ users found", @(users.count)]];
            [self p_getUserThumbnails];
        }
    }];
}

#pragma mark - Private Methods

-(void) p_fetchOnlineUsers
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Refreshing";
    
    self.onlineUsers = nil;
    self.userViewControllers = nil;
    self.userThumbnails = nil;
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *fluentLanguage = currentUser[PF_USER_FLUENT_LANGUAGE];
    NSString *desiredLanague = currentUser[PF_USER_DESIRED_LANGUAGE];
    
    PFQuery *language1 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [language1 whereKey:PF_USER_FLUENT_LANGUAGE equalTo:desiredLanague];
    [language1 whereKey:PF_USER_DESIRED_LANGUAGE equalTo:fluentLanguage];
    
    PFQuery *language2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [language2 whereKey:PF_USER_FLUENT_LANGUAGE2 equalTo:desiredLanague];
    [language2 whereKey:PF_USER_DESIRED_LANGUAGE equalTo:fluentLanguage];
    
    PFQuery *language3 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [language3 whereKey:PF_USER_FLUENT_LANGUAGE3 equalTo:desiredLanague];
    [language3 whereKey:PF_USER_DESIRED_LANGUAGE equalTo:fluentLanguage];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[language1, language2, language3]];
    [query whereKey:PF_USER_ONLINE equalTo:@(YES)];
    [query setLimit:20];
    
    [query  findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (error != nil) {
            NSLog(@"No connection");
            [hud hide:YES afterDelay:2.0];
        } else {
            self.onlineUsers = [users mutableCopy];
            if (users.count != 0) {
                [self p_getUserThumbnails];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self p_showStatusBarWithText:@"No users online"];
                [self.tableView reloadData];
            }
        }
    }];
}

-(void) p_getUserThumbnails
{
    for (PFUser *user in self.onlineUsers) {
        PFFile *thumbnail = user[PF_USER_THUMBNAIL];
        
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error != nil) {
                NSLog(@"Error retreiving thumbnail");
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *thumbnailImage = [UIImage imageWithData:data];
                    if (self.userThumbnails == nil) {
                        self.userThumbnails = [[NSMutableDictionary alloc] init];
                    }
                    
                    if (![self.userThumbnails objectForKey:user.objectId]) {
                        [self.userThumbnails setObject:thumbnailImage forKey:user.objectId];
                    }
                    
                    [self.tableView reloadData];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                });
                
            }
        }];
    }
}


-(void) p_showStatusBarWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud hide:YES afterDelay:2.0];
}

@end
