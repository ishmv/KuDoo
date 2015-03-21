#import "LMChatsListViewController.h"
#import "LMFriendsListView.h"
#import "LMChat.h"
#import "LMUsers.h"
#import <Parse/Parse.h>
#import "LMChatViewController.h"
#import "AppConstant.h"
#import "ChatView.h"
#import "LMUserProfileViewController.h"

@interface LMChatsListViewController () <LMFriendsListViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;
@property (strong, nonatomic) UIButton *addChatButton;

@end

static NSString *reuseIdentifier = @"FriendCell";

@implementation LMChatsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-321-like.png"]];
        self.tabBarItem.title = @"Chats";
        
        self.addChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.addChatButton setTitle:@"Start New Chat" forState:UIControlStateNormal];
        [self.addChatButton addTarget:self action:@selector(addChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //Keep!
        [LMChat sharedInstance];
        [[LMChat sharedInstance] addObserver:self forKeyPath:@"chats" options:0 context:nil];
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
    [[LMChat sharedInstance] getChatsForCurrentUser];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.delegate = self;
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"chat with %@", chat[PF_CHAT_TITLE]];
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
    
    PFObject *chat = [self chats][indexPath.row];
    NSString *groupID = chat[PF_CHAT_GROUPID];
    
    ChatView *chatVC = [[ChatView alloc] initWithGroupId:groupID];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
    
//    [self initiateChatWithGroupID:groupID];
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
    UIAlertView *chooseChatType = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Select Chat Type", @"Select Chat Type")
                                                             message:NSLocalizedString(@"Who?", @"Who would you like to chat with?")
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Friend", @"Find me Someone", nil];
    
    chooseChatType.delegate = self;
    chooseChatType.alertViewStyle = UIAlertViewStyleDefault;
    
    [chooseChatType show];
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            //Present Friends
            break;
        }
        case 2:
        {
            [self startChatWithRandomUser];
            break;
        }
            
        default:
        {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            break;
        }
    }
}

-(void)startChatWithRandomUser
{
    //ToDo you are now chatting with username... and loading Screen
    
    [[LMUsers sharedInstance] findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
        if (user)
        {
            [[LMChat sharedInstance] startChatWithUsers:@[user] completion:^(NSString *groupId, NSError *error) {
                [self initiateChatWithGroupID:groupId];
            }];
        }
    }];
}


-(void)initiateChatWithGroupID: (NSString *)groupID
{
//    LMChatViewController *chatVC = [[LMChatViewController alloc] initWithGroupId:groupID];
//    chatVC.hidesBottomBarWhenPushed = YES;
//    [[LMChat sharedInstance] saveChat:groupID];
//    [self.navigationController pushViewController:chatVC animated:YES];

    ChatView *chatVC = [[ChatView alloc] initWithGroupId:groupID];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}


@end