#import "LMChatsListViewController.h"
#import "LMFriendsListView.h"
#import "LMChat.h"
#import "LMUsers.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ChatView.h"
#import "LMUserProfileViewController.h"
#import "LMChatListCell.h"
#import "LMData.h"

@interface LMChatsListViewController () <LMFriendsListViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;


@end

static NSString *reuseIdentifier = @"ChatCell";

@implementation LMChatsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-321-like.png"]];
        self.tabBarItem.title = @"Chats";
        
        //Keep!
//        [LMChat sharedInstance];
//        [[LMChat sharedInstance] addObserver:self forKeyPath:@"chats" options:0 context:nil];
        [LMData sharedInstance];
        
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
//    [[LMChat sharedInstance] getChatsForCurrentUser];
    
    UIBarButtonItem *startNewChat = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addChatButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:startNewChat];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.delegate = self;
    [self.friendsView.tableView registerClass:[LMChatListCell class] forCellReuseIdentifier:reuseIdentifier];
   
    [self.view addSubview:self.friendsView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
//    [[LMChat sharedInstance] removeObserver:self forKeyPath:@"chats"];
}

#pragma mark - UITableView Data Source

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFObject *chat = [self chats][indexPath.row];
    cell.chat = chat;
    
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
//    NSString *groupID = chat[PF_CHAT_GROUPID];
    
    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
    
//    [self initiateChatWithGroupID:groupID];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Friends";
    } else {
        return @"Random";
    }
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
    return [LMData sharedInstance].chats;
//    return [LMChat sharedInstance].chats;
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
            [[LMChat sharedInstance] startChatWithUsers:@[user] completion:^(PFObject *chat, NSError *error) {
                [self initiateChatWithObject:chat];
            }];
        }
    }];
}


-(void)initiateChatWithObject: (PFObject *)chat
{
//    LMChatViewController *chatVC = [[LMChatViewController alloc] initWithGroupId:groupID];
//    chatVC.hidesBottomBarWhenPushed = YES;
//    [[LMChat sharedInstance] saveChat:groupID];
//    [self.navigationController pushViewController:chatVC animated:YES];

    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}


@end