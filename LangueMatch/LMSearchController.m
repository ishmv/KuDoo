#import "LMSearchController.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMFriendsListViewCell.h"

#import <Parse/Parse.h>
#import <SVProgressHUD.h>

typedef NS_ENUM(NSInteger, searchScope) {
    searchScopeUsername = 0,
    searchScopeLanguage = 1
};

static NSString *reuseIdentifier = @"FriendCell";

@interface LMSearchController() <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;

@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation LMSearchController

-(instancetype) init
{
    if (self = [super init]) {
        _searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    }
    return self;
}

-(void)dealloc
{
    self.searchResults = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:searchButton];
    
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
    self.searchController.searchBar.placeholder = @"Search LangueMatch";
    self.searchController.searchBar.showsScopeBar = NO;
    self.searchController.searchBar.scopeButtonTitles = @[@"Username", @"Language"];
    self.searchController.searchBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.searchController.searchBar sizeToFit];
}

#pragma mark - Search Results Updating

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //Handled in dealloc
}

#pragma mark - Search Bar Delegate

-(void)searchButtonPressed:(UIButton *)sender
{
    NSString *searchText = [self.searchController.searchBar.text lowercaseString];
    
    if ([searchText length] == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Need Something to search", @"Need Something To Search")];
    } else {
        
        NSInteger scopeSelected = self.searchController.searchBar.selectedScopeButtonIndex;
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"Searching") maskType:SVProgressHUDMaskTypeClear];
        
        if (!_searchResults) {
            _searchResults = [NSArray array];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        
        if (scopeSelected == searchScopeUsername) {
            [query whereKey:PF_USER_USERNAME_LOWERCASE equalTo:searchText];
            
        } else if (scopeSelected == searchScopeLanguage) {
            [query whereKey:PF_USER_FLUENT_LANGUAGE equalTo:searchText];
            [query setLimit:20];
        }
        
        //Need timeout provision
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count == 0) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Results", @"No Results") maskType:SVProgressHUDMaskTypeClear];
            } else if (error) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(error.description, error.description) maskType:SVProgressHUDMaskTypeClear];
            } else {
                NSString *matches = [NSString stringWithFormat:@"Found %@ matches", @(objects.count)];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(matches, matches) maskType:SVProgressHUDMaskTypeClear];
                _searchResults = objects;
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


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}


@end
