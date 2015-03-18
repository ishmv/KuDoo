#import "LMFriendsListViewController.h"
#import "LMFriendsListView.h"
#import "LMUsers.h"
#import <Parse/Parse.h>
#import "LMChatViewController.h"
#import "LMChat.h"
#import "LMFriendsListViewCell.h"

@interface LMFriendsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;

@end

static NSString *reuseIdentifier = @"FriendCell";

@implementation LMFriendsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-305-palm-tree.png"]];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[LMUsers sharedInstance] addObserver:self forKeyPath:@"users" options:0 context:nil];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.tableView.dataSource = self;
    self.friendsView.tableView.delegate = self;
    [self.friendsView.tableView registerClass:[LMFriendsListViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.friendsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[LMUsers sharedInstance] removeObserver:self forKeyPath:@"users"];
}

#pragma mark - UITableView Data Source

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMFriendsListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMFriendsListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user = [self users][indexPath.row];
    cell.user = user;
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self users].count;
}


#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Show User Profile
    //Option to start chat at bottom
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - KVO on Users

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [LMUsers sharedInstance] && [keyPath isEqualToString:@"users"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.friendsView.tableView reloadData];
        }
    }
}

-(NSArray *) users
{
    return [LMUsers sharedInstance].users;
}


@end
