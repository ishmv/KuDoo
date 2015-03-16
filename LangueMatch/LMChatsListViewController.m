#import "LMChatsListViewController.h"
#import "LMFriendsListView.h"
#import "LMChat.h"
#import "LMUsers.h"
#import <Parse/Parse.h>
#import "LMChatViewController.h"

@interface LMChatsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;
@property (strong, nonatomic) UIButton *addChatButton;

@end

static NSString *const reuseIdentifier = @"Cell";

@implementation LMChatsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-321-like.png"]];
        self.tabBarItem.title = @"Chats";
        
        self.addChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.addChatButton setTitle:@"Start New Chat" forState:UIControlStateNormal];
        [self.addChatButton addTarget:self action:@selector(addChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.friendsView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height);
    self.addChatButton.frame = CGRectMake(50, CGRectGetMaxY(self.navigationController.navigationBar.frame), 200, 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[LMChat sharedInstance] addObserver:self forKeyPath:@"chats" options:0 context:nil];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.tableView.dataSource = self;
    self.friendsView.tableView.delegate = self;
    [self.friendsView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
   
    [self.view addSubview:self.friendsView];
    [self.view addSubview:self.addChatButton];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[LMChat sharedInstance] removeObserver:self forKeyPath:@"chats"];
}

#pragma mark - UITableView Data Source

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFObject *chat = [self chats][indexPath.row];
    
    cell.textLabel.text = chat[@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self chats].count;
}


#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    PFObject *chat = [self chats][indexPath.row];
//    LMChatViewController *chatVC = [[LMChatViewController alloc] initWithChat:chat];
//    chatVC.title = chat[@"title"];
//    chatVC.hidesBottomBarWhenPushed = YES;
//
//    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - KVO on Users

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [LMChat sharedInstance] && [keyPath isEqualToString:@"chats"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.friendsView.tableView reloadData];
        }
    }
}

-(NSArray *) chats
{
    return [LMChat sharedInstance].chats;
}

#pragma mark - Target Action Methods
-(void) addChatButtonPressed:(UIButton *)sender
{
    [[LMChat sharedInstance] startChatWithLMUsers:[LMUsers sharedInstance].users completion:^(NSString *groupID, NSError *error) {
        LMChatViewController *chatVC = [[LMChatViewController alloc] initWithGroupId:groupID];
        chatVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatVC animated:YES];
    }];
}

@end