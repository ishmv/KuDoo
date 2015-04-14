#import "LMFriendsListViewController.h"
#import "LMFriendsListView.h"
#import "LMFriendsListViewCell.h"
#import "LMUserProfileViewController.h"
#import "LMSearchController.h"

#import "LMFriendsModel.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendsListViewController () <LMFriendsListViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;
@property (strong, nonatomic) LMFriendsModel *friendModel;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (strong, nonatomic) NSMutableArray *filteredResults;

@end

static NSString *reuseIdentifier = @"FriendCell";
static CGFloat const cellHeight = 70;

@implementation LMFriendsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        if (!_friendModel) {
            _friendModel = [[LMFriendsModel alloc] init];
        }
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"globe.png"]];
        self.tabBarItem.title = @"Friends";
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.friendsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSearchController];
    
    //Register For Key Value Notifications from LMFriendsModel
    [self.friendModel addObserver:self forKeyPath:@"friendList" options:0 context:nil];
    
    UIBarButtonItem *addContact = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactButtonPressed)];
    [self.navigationItem setRightBarButtonItem:addContact];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.delegate = self;
    [self.friendsView.tableView registerClass:[LMFriendsListViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.friendsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //Drop model and images;
}

-(void)dealloc
{
    [self.friendModel removeObserver:self forKeyPath:@"friendList"];
}

-(void) loadSearchController
{
    self.searchResultsController = [[UITableViewController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultsController];
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder = @"Search Friends";
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    self.searchResultsController.tableView.delegate = self;
    self.searchResultsController.tableView.dataSource = self;
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
}

#pragma mark - Search Methods

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    [self searchFriendsListForText:searchString];
}

-(void) searchFriendsListForText:(NSString *)text
{
    NSMutableArray *localFilteredArray = [NSMutableArray array];
    
    if (text.length != 0) {
        for (PFUser *user in [self friends]) {
            NSArray *stringArray = [NSArray arrayWithObjects:user.username,user[PF_USER_DESIRED_LANGUAGE], user[PF_USER_FLUENT_LANGUAGE], user[PF_USER_EMAIL], nil];
            
            for (NSString *string in stringArray) {
                if ([string rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [localFilteredArray addObject:user];
                    break;
                }
            }
        }
    }
    
    self.filteredResults = localFilteredArray;
    [self.searchResultsController.tableView reloadData];
}

#pragma mark - UITableView Data Source

/* -- Accomodates both friend list and search query -- */

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LMFriendsListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMFriendsListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user;
    
    if (tableView == _friendsView.tableView) {
        user = [self friends][indexPath.row];
    } else {
        user = _filteredResults[indexPath.row];
    }
    
    cell.user = user;
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _friendsView.tableView) {
        return [self friends].count;
    } else {
        return _filteredResults.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView != _friendsView.tableView) {
        if (self.filteredResults.count == 0) {
            return 70;
        }
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *noResultsLabel;
    if (tableView != _friendsView.tableView) {
        if (self.filteredResults.count == 0) {
            noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 70)];
            noResultsLabel.textAlignment = NSTextAlignmentCenter;
            tableView.separatorColor = [UIColor whiteColor];
            [noResultsLabel setText:@"No results"];
        }
    }
    return noResultsLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == _friendsView.tableView) {
        return 40;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *inviteFriendsButton = nil;
    if (tableView == _friendsView.tableView) {
        inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        inviteFriendsButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40);
        [inviteFriendsButton setTitle:@"Invite Friends to LangueMatch" forState:UIControlStateNormal];
    }
    return inviteFriendsButton;
}

#pragma mark - UITableView Delegate

/* -- Show user profile when tapped and have option to chat -- */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *user = [self friends][indexPath.row];
    
    LMUserProfileViewController *userVC = [[LMUserProfileViewController alloc] initWith:user];
    [self.navigationController pushViewController:userVC animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

#pragma mark - Friends Array

-(NSArray *) friends
{
    return [self.friendModel friendList];
}

#pragma mark - Target Action

/* -- Query LangueMatch user database against users or language -- */

-(void) addContactButtonPressed
{
    LMSearchController *searchController = [[LMSearchController alloc] init];
    [self.navigationController pushViewController:searchController animated:YES];
}

#pragma mark - Key/Value Observing

/* -- Observe user chat list to complete download then update tableview with results -- */

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"friendList"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.friendsView.tableView reloadData];
        }
    }
}
@end
