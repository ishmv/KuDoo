#import "LMFriendsListViewController.h"
#import "LMFriendsListView.h"
#import "LMUsers.h"
#import <Parse/Parse.h>
#import "LMChatViewController.h"

@interface LMFriendsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;

@end

static NSString *const reuseIdentifier = @"Cell";

@implementation LMFriendsListViewController

-(instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.friendsView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[LMUsers sharedInstance] addObserver:self forKeyPath:@"users" options:0 context:nil];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.tableView.dataSource = self;
    self.friendsView.tableView.delegate = self;
    [self.friendsView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user = [self users][indexPath.row];

    cell.textLabel.text = user.username;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    
    LMChatViewController *chatVC = [[LMChatViewController alloc] initWithUsers:@[[self users][indexPath.row]]];
    [self.navigationController pushViewController:chatVC animated:YES];
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
