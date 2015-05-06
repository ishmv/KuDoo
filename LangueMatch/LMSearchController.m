#import "LMSearchController.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMFriendsListViewCell.h"
#import "LMParseConnection.h"
#import "LMSearchedUserProfileViewController.h"

#import <Parse/Parse.h>
#import <SVProgressHUD.h>

typedef NS_ENUM(NSInteger, searchScope)
{
    searchScopeUsername             = 0,
    searchScopeLearningLanguage     = 1,
    searchScopeFluentLanguage       = 2
};

static NSString *reuseIdentifier = @"FriendCell";

@interface LMSearchController() <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;

@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation LMSearchController

#pragma mark - View Controller Life Cycle

-(instancetype) init
{
    if (self = [super init]) {
        _searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[LMListViewCell class] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search Users...";
    self.searchController.searchBar.scopeButtonTitles = @[@"Username", @"Learning Language", @"Fluent Language"];
    self.searchController.searchBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.searchController.searchBar.showsScopeBar = YES;
    [self.searchController.searchBar sizeToFit];
}

-(void)dealloc
{
    self.searchResults = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Search Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = [self.searchController.searchBar.text lowercaseString];
    
    if ([searchText length] == 0)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Need Something to search", @"Need Something To Search")];
    }
    else
    {
        NSInteger scopeSelected = self.searchController.searchBar.selectedScopeButtonIndex;
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"Searching") maskType:SVProgressHUDMaskTypeClear];
        
        if (!_searchResults) _searchResults = [NSArray array];
        
        NSMutableDictionary *searchCritera = [[NSMutableDictionary alloc] init];
        
        if (scopeSelected == searchScopeUsername) [searchCritera setValue:searchText forKey:PF_USER_USERNAME];
        else if (scopeSelected == searchScopeLearningLanguage) [searchCritera setValue:searchText forKey:PF_USER_DESIRED_LANGUAGE];
        else if (scopeSelected == searchScopeFluentLanguage) [searchCritera setValue:searchText forKey:PF_USER_FLUENT_LANGUAGE];

        [LMParseConnection searchUsersWithCriteria:searchCritera withCompletion:^(NSArray *users, NSError *error) {
            if (users.count == 0)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Results", @"No Results") maskType:SVProgressHUDMaskTypeClear];
            }
            else if (error)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(error.description, error.description) maskType:SVProgressHUDMaskTypeClear];
            }
            else
            {
                NSString *matches = [NSString stringWithFormat:@"Found %@ matches", @(users.count)];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(matches, matches) maskType:SVProgressHUDMaskTypeClear];
                _searchResults = users;
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user = self.searchResults[indexPath.row];
    cell.user = user;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *user = _searchResults[indexPath.row];
    
    LMSearchedUserProfileViewController *userVC = [[LMSearchedUserProfileViewController alloc] initWith:user];
    [self.navigationController pushViewController:userVC animated:YES];
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}


@end
