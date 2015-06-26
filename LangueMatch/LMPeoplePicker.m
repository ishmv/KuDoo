#import "LMPeoplePicker.h"
#import "ParseConnection.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "UIColor+applicationColors.h"

@interface LMPeoplePicker ()

@property (strong, nonatomic) NSOrderedSet *contacts;

@property (strong, nonatomic) NSMutableArray *chatParticipants;
@property (strong, nonatomic) NSMutableOrderedSet *searchResultsContacts;
@property (strong, nonatomic) NSMutableOrderedSet *searchResultsOnline;

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation LMPeoplePicker

static NSString *const reuseIdentifier = @"reuseIdentifier";


#pragma mark - View Controller Life Cycle

-(instancetype) initWithContacts:(NSOrderedSet *)contacts
{
    if (self = [super init]) {
        _contacts = contacts;
        _searchResultsContacts = [[NSMutableOrderedSet alloc] initWithOrderedSet:contacts];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_noteWorthyLargeBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"New Chat", @"new chat")];
    [self.navigationItem setTitleView:titleLabel];
    
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search username", @"search username");
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.barTintColor = [UIColor lm_beigeColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;

    UIBarButtonItem *startChatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(checkmarkButtonPressed:)];
    self.navigationItem.rightBarButtonItem = startChatButton;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.chatParticipants.count;
            break;
        case 1:
            return self.searchResultsContacts.count;
            break;
        case 2:
            return self.searchResultsOnline.count;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user;
    UILabel *addToChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    [addToChatLabel.layer setCornerRadius:12.5f];
    [addToChatLabel.layer setBorderColor:[UIColor lm_wetAsphaltColor].CGColor];
    [addToChatLabel.layer setBorderWidth:1.0f];
    [addToChatLabel.layer setMasksToBounds:YES];
    addToChatLabel.textAlignment = NSTextAlignmentCenter;
    addToChatLabel.font = [UIFont lm_noteWorthyMedium];
    addToChatLabel.textColor = [UIColor lm_wetAsphaltColor];
    
    switch (indexPath.section) {
        case 0:
            user = self.chatParticipants[indexPath.row];
            addToChatLabel.text = @"-";
            break;
        case 1:
            user = self.searchResultsContacts[indexPath.row];
            addToChatLabel.text = @"+";
            break;
        case 2:
            user = self.searchResultsOnline[indexPath.row];
            addToChatLabel.text = @"+";
            break;
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = user[PF_USER_DISPLAYNAME];
    cell.textLabel.textColor = [UIColor lm_orangeColor];
    cell.textLabel.font = [UIFont lm_noteWorthyMedium];
    cell.accessoryView = addToChatLabel;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Participants", @"participants");
            break;
        case 1:
            return NSLocalizedString(@"Contacts", @"contacts");
            break;
        case 2:
            return NSLocalizedString(@"Online", @"online");
            break;
        default:
            break;
    }

    
    return @"";
}



#pragma mark - Search Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (!_searchResultsOnline) {
        self.searchResultsOnline = [[NSMutableOrderedSet alloc] init];
    }
    
    [ParseConnection searchForUsername:searchBar.text withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
        for (PFUser *user in objects) {
            [self p_addUserToOnlineSearchResults:user];
        }
        [self.tableView reloadData];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!_searchResultsContacts) {
        self.searchResultsContacts = [[NSMutableOrderedSet alloc] init];
    }
    
    for (PFUser *user in self.contacts) {
        if ([user.username containsString:[searchText lowercaseString]]) [self.searchResultsContacts addObject:user];
        else [self.searchResultsContacts removeObject:user];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Search Controller Delegate

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *user;
    
    if (!_chatParticipants) {
        _chatParticipants = [[NSMutableArray alloc] init];
    }
    
    switch (indexPath.section) {
        case 0:
            user = self.chatParticipants[indexPath.row];
            [self.chatParticipants removeObject:user];
            break;
        case 1:
            user = self.searchResultsContacts[indexPath.row];
            [self p_addUserToChatParticipants:user];
            break;
        case 2:
            user = self.searchResultsOnline[indexPath.row];
            [self p_addUserToChatParticipants:user];
            break;
        default:
            break;
    }
    
    [self.searchResultsContacts removeAllObjects];
    [self.searchResultsOnline removeAllObjects];
    self.searchController.searchBar.text = nil;
    [self.searchController.searchBar resignFirstResponder];
    
    [self.tableView reloadData];
}

-(void) p_addUserToChatParticipants:(PFUser *)user
{
    NSString *userId = user.objectId;
    
    for (PFUser *user in self.chatParticipants) {
        if ([userId isEqualToString:user.objectId]) {
            return;
        }
    }
    
    [self.chatParticipants addObject:user];
    
}

-(void) p_addUserToOnlineSearchResults:(PFUser *)user
{
    NSString *userId = user.objectId;
    
    for (PFUser *user in self.searchResultsOnline) {
        if ([userId isEqualToString:user.objectId]) {
            return;
        }
    }
    
    [self.searchResultsOnline addObject:user];
}

#pragma mark - Touch Handling
-(void)checkmarkButtonPressed:(UIButton *)sender
{
    if (self.chatParticipants.count == 0) {
        UIAlertView *noOneSelectedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Selection", @"no selection") message:NSLocalizedString(@"Select at least one person", @"select at least one person") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noOneSelectedAlert show];
        return;
    } else {
        if ([self.delegate respondsToSelector:@selector(LMPeoplePicker:didFinishPickingPeople:)]) {
            [self.delegate LMPeoplePicker:self didFinishPickingPeople:self.chatParticipants];
        }
    }
}

@end
