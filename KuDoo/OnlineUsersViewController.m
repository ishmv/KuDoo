#import "OnlineUsersViewController.h"
#import "AppConstant.h"
#import "LMTableViewCell.h"
#import "LMOnlineUserProfileViewController.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "ParseConnection.h"
#import "LMUserViewModel.h"
#import "LMSearchMenu.h"
#import "LMLanguageOptionsTableView.h"
#import "NSArray+LanguageOptions.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface OnlineUsersViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, LMSearchMenuDelegate, LMLanguageOptionsTableViewDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (assign, nonatomic) NSInteger searchType;
@property (strong, nonatomic) NSString *searchParameter;

@property (strong, nonatomic) NSMutableArray *onlineUsers;
@property (strong, nonatomic) NSMutableDictionary *userViewControllers;
@property (strong, nonatomic) NSMutableDictionary *userThumbnails;

@property (strong, nonatomic) LMSearchMenu *searchMenu;
@property (strong, nonatomic) LMLanguageOptionsTableView *languageOptions;
@property (assign, nonatomic) LMLanguageSelectionType selectionType;

@end

@implementation OnlineUsersViewController

static NSString *reuseIdentifier = @"reuseIdentifier";

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _searchType = 0;
        _searchParameter = @"";
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"online"]];
        self.tabBarItem.title = NSLocalizedString(@"People", @"people");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *menuButton = ({
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"typing"] style:UIBarButtonItemStylePlain target:self action:@selector(p_selectSearchFilter)];
        barButtonItem;
    });
    
    self.searchController = ({
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        searchController.searchBar.delegate = self;
        searchController.hidesNavigationBarDuringPresentation = NO;
        searchController.dimsBackgroundDuringPresentation = NO;
        [searchController.searchBar sizeToFit];
        searchController.searchBar.barTintColor = [UIColor lm_slateColor];
        searchController;
    });
    
    self.definesPresentationContext = YES;

    self.refreshControl = ({
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor lm_slateColor];
        [refreshControl addTarget:self action:@selector(p_fetchOnlineUsers) forControlEvents:UIControlEventValueChanged];
        refreshControl;
    });
    
    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont lm_robotoLightLarge]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:NSLocalizedString(@"People", @"people")];
        label;
    });
    
    [self.navigationItem setTitleView:titleLabel];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
    
    self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.frame.size.height);
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.view.backgroundColor = [UIColor lm_slateColor];
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealBlueColor];

    [self p_fetchOnlineUsers];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.searchController.searchBar.layer.borderWidth = 1.0f;
    self.searchController.searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
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
    
    cell.cellImageViewPadding = 12.0f;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor lm_slateColor];
    
    PFUser *user = self.onlineUsers[indexPath.row];
    LMUserViewModel *viewModel = [[LMUserViewModel alloc] initWithUser:user];
    
    cell.cellImageView.image = self.userThumbnails[user.objectId];
    cell.titleLabel.text = user[PF_USER_DISPLAYNAME];
    cell.detailLabel.text = [viewModel fluentLanguageString];
    
    NSString *learningText = [[viewModel desiredLanguageString] stringByReplacingOccurrencesOfString:NSLocalizedString(@"Learning", @"learning") withString:@""];
    cell.accessoryLabel.text = learningText;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = self.onlineUsers[indexPath.row];
    
    LMOnlineUserProfileViewController *userVC;
    
    userVC = [self.userViewControllers objectForKey:user.objectId];
    
    if (!userVC) {
        userVC = [[LMOnlineUserProfileViewController alloc] initWithUser:user];
        userVC.profilePicView.image = self.userThumbnails[user.objectId];
        [self.userViewControllers setObject:userVC forKey:user.objectId];
    }
    
    userVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self.navigationController presentViewController:userVC animated:YES completion:nil];
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
    self.searchParameter = self.searchController.searchBar.text;
    
    [self p_fetchOnlineUsers];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // To Do reload more users after scrolling to the bottom
    }
}

#pragma mark - Private Methods

-(void) p_fetchOnlineUsers
{
    self.onlineUsers = nil;
    self.userViewControllers = nil;
    self.userThumbnails = nil;
    
    [ParseConnection  performSearchType:_searchType withParameter:_searchParameter withCompletion:^(NSArray *users, NSError *error) {
        if (error != nil) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = [NSString lm_parseError:error];
            [hud hide:YES afterDelay:2.0];
        } else {
            self.onlineUsers = [users mutableCopy];
            if (users.count != 0) {
                [self p_getUserThumbnails:users];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self p_showStatusBarWithText:NSLocalizedString(@"No matches", @"no matches")];
                [self.tableView reloadData];
            }
        }
        
        [self.refreshControl endRefreshing];
    }];
}

-(void) p_getUserThumbnails:(NSArray *)users
{
    for (PFUser *user in users) {
        PFFile *thumbnail = user[PF_USER_THUMBNAIL];
        __block UIImage *thumbnailImage = nil;
        
        if (thumbnail != nil) {
            [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (error != nil) {
                    NSLog(@"Error retreiving thumbnail");
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        thumbnailImage = [UIImage imageWithData:data];
                        [self p_saveThumbnail:thumbnailImage forUser:user];
                        
                    });
                }
            }];
        } else {
            thumbnailImage = [UIImage imageNamed:@"emptyProfile"];
            [self p_saveThumbnail:thumbnailImage forUser:user];
        }
    }
}

-(void) p_saveThumbnail:(UIImage *)thumbnailImage forUser:(PFUser *)user
{
    if (self.userThumbnails == nil) {
        self.userThumbnails = [[NSMutableDictionary alloc] init];
    }
    
    if (![self.userThumbnails objectForKey:user.objectId]) {
        [self.userThumbnails setObject:thumbnailImage forKey:user.objectId];
    }
    
    [self.tableView reloadData];
}


-(void) p_showStatusBarWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud hide:YES afterDelay:2.0];
}

-(void) p_selectSearchFilter
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat contentOffset = self.tableView.contentOffset.y;
    
    if (!_searchMenu) {
        self.searchMenu = [[LMSearchMenu alloc] initWithStyle:UITableViewStyleGrouped];
        self.searchMenu.delegate = self;
        self.searchMenu.view.frame = CGRectMake(-viewWidth/1.7f, contentOffset, viewWidth/1.7f, viewHeight/1.5f);
        [self.searchMenu isMovingToParentViewController];
        [self addChildViewController:self.searchMenu];
        [self.view addSubview:self.searchMenu.view];
    }

    if (_searchMenu.view.frame.origin.x < -1) [self p_showSearchMenu];
    else {
        [self p_dismissSearchMenu];
        [self p_hideLanguageOptions];
    }
}


#pragma mark - LMSearchMenu Delegate

-(void) LMSearchMenu:(LMSearchMenu *)searchMenu didSelectOption:(NSInteger)selection
{
    switch (selection) {
        case 3:
        {
            _selectionType = LMLanguageSelectionTypeFluent1;
        }
            [self p_presentLanguageOptions];
            self.searchType = selection;
            return;
        case 4:
        {
            _selectionType = LMLanguageSelectionTypeDesired;
        }
            [self p_presentLanguageOptions];
            self.searchType = selection;
            return;
        default:
            break;
    }
    
    self.searchType = selection;
    self.searchParameter = @"";
    [self p_dismissSearchMenu];
    [self p_fetchOnlineUsers];
}

-(void) p_dismissSearchMenu
{
    [_searchMenu resignFirstResponder];
    [UIView animateWithDuration:0.5f animations:^{
        _searchMenu.view.transform = CGAffineTransformIdentity;
    }];
}

-(void) p_showSearchMenu
{
    CGFloat contentOffset = self.tableView.contentOffset.y;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    self.searchMenu.view.frame = CGRectMake(-viewWidth/1.7f, contentOffset, viewWidth/1.7f, viewHeight/1.5f);
    [_searchMenu.view becomeFirstResponder];
    [self.view bringSubviewToFront:_searchMenu.view];
    [UIView animateWithDuration:0.5f animations:^{
        self.searchMenu.view.transform = CGAffineTransformMakeTranslation(viewWidth/1.7f, 0);
    }];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self p_dismissSearchMenu];
    [self p_hideLanguageOptions];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self p_dismissSearchMenu];
    [self p_hideLanguageOptions];
}

#pragma mark - LMLanguageOptions Delegate

-(void) p_presentLanguageOptions
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat contentOffset = self.tableView.contentOffset.y;
    
    if (!_languageOptions) {
        self.languageOptions = [[LMLanguageOptionsTableView alloc] initWithStyle:UITableViewStyleGrouped];
        self.languageOptions.delegate = self;
        self.languageOptions.view.frame = CGRectMake(-viewWidth/1.7f,contentOffset, viewWidth/1.7f, viewHeight/1.5f);
        [self.languageOptions isMovingToParentViewController];
        [self addChildViewController:self.languageOptions];
        [self.view addSubview:self.languageOptions.view];
    }
    
    if (_languageOptions.view.frame.origin.x < -1) [self p_showLanguageOptions];
    else [self p_hideLanguageOptions];
}

-(void) p_showLanguageOptions
{
    CGFloat contentOffset = self.tableView.contentOffset.y;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    self.languageOptions.view.frame = CGRectMake(-viewWidth/1.7f, contentOffset, viewWidth/1.7f, viewHeight/1.5f);
    [_languageOptions.view becomeFirstResponder];
    [self.view bringSubviewToFront:_languageOptions.view];
    [UIView animateWithDuration:0.5f animations:^{
        self.languageOptions.view.transform = CGAffineTransformMakeTranslation(viewWidth/1.7f, 0);
    }];
}

-(void) p_hideLanguageOptions
{
    [_languageOptions resignFirstResponder];
    [UIView animateWithDuration:0.5f animations:^{
        _languageOptions.view.transform = CGAffineTransformIdentity;
    }];
}

-(void)LMLanguageOptionsTableView:(LMLanguageOptionsTableView *)tableView didSelectLanguage:(NSInteger)index
{
    if (index == 0) {
        [self p_hideLanguageOptions];
        return;
    }
    
    self.searchParameter = [NSArray lm_languageOptionsEnglish][index];
    [self p_hideLanguageOptions];
    [self p_dismissSearchMenu];
    [self p_fetchOnlineUsers];
}

@end