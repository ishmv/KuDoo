#import "LMFriendsListViewController.h"
#import "LMListView.h"
#import "LMFriendListCell.h"
#import "LMUserProfileViewController.h"
#import "LMSearchController.h"
#import "LMFriendRequestViewController.h"
#import "LMSlideView.h"

#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMGlobalVariables.h"
#import "LMFriendsModel.h"
#import "AppConstant.h"
#import "Utility.h"

#import <Parse/Parse.h>

@interface LMFriendsListViewController () <LMListViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, LMFriendRequestViewControllerDelegate, LMSlideViewDelegate>

@property (strong, nonatomic) UILabel *friendRequestLabel;
@property (strong, nonatomic) LMListView *friendsView;
@property (strong, nonatomic) LMFriendRequestViewController *friendRequestVC;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (strong, nonatomic) NSMutableArray *filteredResults;

@property (nonatomic, assign) NSNumber *friendRequestCount;

@end

static NSString *reuseIdentifier = @"FriendCell";
static CGFloat const cellHeight = 70;

@implementation LMFriendsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [LMFriendsModel sharedInstance];
        
        if (!_friendRequestVC) _friendRequestVC = [[LMFriendRequestViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.friendRequestVC.title = @"Friend Requests";
        self.friendRequestVC.delegate = self;
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"world.png"]];
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
    
    [self p_loadSearchController];
    [self p_renderBackgroundColor];
    
    [[LMFriendsModel sharedInstance] addObserver:self forKeyPath:@"friendList" options:0 context:nil];
    
    UIBarButtonItem *addContact = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"follow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addContactButtonPressed)];
    [self.navigationItem setRightBarButtonItem:addContact];
    
    self.friendsView = [[LMListView alloc] init];
    self.friendsView.delegate = self;
    [self.friendsView.tableView registerClass:[LMFriendListCell class] forCellReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.friendsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc
{
    [[LMFriendsModel sharedInstance] removeObserver:self forKeyPath:@"friendList"];
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
        for (PFUser *user in [self p_friends]) {
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

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user;
    user = (tableView == self.friendsView.tableView) ? [self p_friends][indexPath.row] : _filteredResults[indexPath.row];
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
        return [self p_friends].count;
    } else {
        return _filteredResults.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.friendRequestCount intValue] > 0) return 44;
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    LMSlideView *slideView = [[LMSlideView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    slideView.labelText = @"> OOH THAT TICKLES";
    slideView.swipeDirection = UISwipeGestureRecognizerDirectionRight;
    slideView.delegate = self;

    return slideView;
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
        inviteFriendsButton.backgroundColor = [UIColor clearColor];
        inviteFriendsButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40);
//        [inviteFriendsButton setTitle:@"Invite Friends to LangueMatch" forState:UIControlStateNormal];
    }
    return inviteFriendsButton;
}

#pragma mark - UITableView Delegate

/* -- Show user profile when tapped and have option to chat -- */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *user = [self p_friends][indexPath.row];
    
    LMUserProfileViewController *userVC = [[LMUserProfileViewController alloc] initWith:user];
    [self.navigationController pushViewController:userVC animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

#pragma mark - LMFriendRequestViewController Delegate

-(void) newFriendRequestCount:(NSNumber *)requests
{
    self.friendRequestCount = requests;
    
    if ([requests intValue] != 0) [self.tabBarItem setBadgeValue:[requests stringValue]];
    else
    {
        self.tabBarItem.badgeValue = nil;
    }
    
    [self.friendsView.tableView reloadData];
}

-(void) addUserToFriendList:(PFUser *)user
{
    [[LMFriendsModel sharedInstance] addFriend:user];
}

#pragma mark - Touch Handling

-(void) addContactButtonPressed
{
    LMSearchController *searchController = [[LMSearchController alloc] init];
    searchController.title = @"Search";
    [self.navigationController pushViewController:searchController animated:YES];
}

-(void) viewSwipedWithGestureRecognizer:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self.navigationController pushViewController:self.friendRequestVC animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    }];
}


#pragma mark - Private Methods

-(NSArray *) p_friends
{
    return [[LMFriendsModel sharedInstance] friendList];
}

-(void) p_renderBackgroundColor
{
    CALayer *imageLayer = [LMGlobalVariables spaceImageBackgroundLayer];
    imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view.layer addSublayer:imageLayer];
    
    CALayer *colorLayer = [LMGlobalVariables wetAsphaltWithOpacityBackgroundLayer];
    colorLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view.layer addSublayer:colorLayer];
    
//    [self.searchResultsController.view.layer addSublayer:imageLayer];
//    [self.searchResultsController.view.layer addSublayer:colorLayer];
}

-(void) p_loadSearchController
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
    
    self.searchResultsController.tableView.backgroundColor = [UIColor lm_wetAsphaltColor];
    self.searchResultsController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Key/Value Observing

/* -- Observe user chat list to complete download then update tableview with results -- */

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"friendList"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting || kindOfChange == NSKeyValueChangeInsertion) {
            [self.friendsView.tableView reloadData];
        }
        else if (kindOfChange == NSKeyValueChangeInsertion ||
                 kindOfChange == NSKeyValueChangeRemoval ||
                 kindOfChange == NSKeyValueChangeReplacement) {
            // We have an incremental change: inserted, deleted, or replaced images
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call `beginUpdates` to tell the table view we're about to make changes
            [self.friendsView.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.friendsView.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.friendsView.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.friendsView.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.friendsView.tableView endUpdates];
        }
    }
}
@end
