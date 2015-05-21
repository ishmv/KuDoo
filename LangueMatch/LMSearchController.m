#import "LMSearchController.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMFriendListCell.h"
#import "LMGlobalVariables.h"
#import "LMParseConnection+Friends.h"
#import "LMSearchedUserProfileViewController.h"
#import "LMFriendsModel.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"

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

@property (strong, nonatomic) UILabel *searchHelp;

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
    
    [self p_renderBackground];
    [self p_setupSearchHelpLabel];
    
    [self.tableView registerClass:[LMFriendListCell class] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.prompt = @"FOR USERNAME...";

    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.scopeButtonTitles = @[@"USERNAME", @"LEARNING", @"FLUENT"];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.searchController.searchBar.showsScopeBar = NO;
    [self.searchController.searchBar sizeToFit];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize viewSize = self.view.frame.size;
    CGSize labelSize = self.searchHelp.frame.size;
    
    self.searchHelp.frame = CGRectMake(viewSize.width/2 - labelSize.width/2, viewSize.height/3.5 - labelSize.height/2, 250, 125);
    [self.view addSubview:self.searchHelp];
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
    self.searchHelp = nil;
    
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
            
            NSArray *friends =[[LMFriendsModel sharedInstance] friendList];
            NSMutableArray *excludeFriends = [NSMutableArray array];
            
            for (PFUser *user in users) {
                if (![friends containsObject:user]) {
                    [excludeFriends addObject:user];
                }
            }
            
            if (excludeFriends.count == 0)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Results", @"No Results") maskType:SVProgressHUDMaskTypeClear];
            }
            else if (error)
            {
                [SVProgressHUD showErrorWithStatus:[LMGlobalVariables parseError:error] maskType:SVProgressHUDMaskTypeClear];
            }
            else
            {
                NSString *matches = [NSString stringWithFormat:@"Found %@ matches", @(excludeFriends.count)];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(matches, matches) maskType:SVProgressHUDMaskTypeClear];
                
                _searchResults = excludeFriends;
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
    LMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user = self.searchResults[indexPath.row];
    cell.user = user;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    fadeOutAnimation.duration = 1;
    [self.searchHelp.layer addAnimation:fadeOutAnimation forKey:nil];
    
    [self.searchHelp.layer setOpacity:0.0f];
}

-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchHelp.layer setOpacity:1.0f];
}

#pragma mark - UISearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    switch (selectedScope) {
        case 0:
            self.searchController.searchBar.prompt = @"FOR USERNAME...";
            break;
        case 1:
            self.searchController.searchBar.prompt = @"USERS LEARNING...";
            break;
        case 2:
            self.searchController.searchBar.prompt = @"USERS FLUENT IN...";
            break;
        default:
            break;
    }
}

#pragma mark - Private Methods

-(void) p_renderBackground
{
    [self.view setBackgroundColor:[UIColor lm_wetAsphaltColor]];
    [self.searchResultsController.tableView setBackgroundColor:[UIColor clearColor]];
}


-(void) p_setupSearchHelpLabel
{
    self.searchHelp = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"SEARCH FOR OTHER LANGUAGE LEARNERS AROUND THE WORLD.";
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont lm_noteWorthyMedium];
        [label setTextColor:[UIColor lm_tealColor]];
        label.numberOfLines = 0;
        label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
        [label.layer setCornerRadius:10.0f];
        [label.layer setMasksToBounds:YES];
        [label sizeToFit];
        label;
    });
}

@end
