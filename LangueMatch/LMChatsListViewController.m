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
@property (strong, nonatomic) UIAlertController *alertController;


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
            //Present Friends List - select user
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
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Finding a Partner", @"Finding a Partner")
                                                                                 message:NSLocalizedString(@"One Second", @"One Second") preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CGRectGetWidth(alertViewController.view.bounds)/2 - 50, 125);
    [alertViewController.view addSubview:spinner];
    [spinner startAnimating];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
    
    [[LMUsers sharedInstance] findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
        if (user)
        {
            PFFile *userImage = user[PF_USER_THUMBNAIL];
            
            [userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             
             {
                 if (!error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIImageView *userPicture = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                         
                         [alertViewController dismissViewControllerAnimated:YES completion:^{
                             [spinner stopAnimating];
                             
                             self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"We Got One! \n chatting With: \n", @"We Got One!")
                                                                                        message:[NSString stringWithFormat:@"%@", user.username]
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                             
                             userPicture.frame = CGRectMake(0, 0, 75, 75);
                             userPicture.contentMode = UIViewContentModeScaleAspectFill;
                             [self.alertController.view addSubview:userPicture];
                             
                             [self presentViewController:self.alertController animated:YES completion:^{
                                 
                                 [[LMChat sharedInstance] startChatWithRandomUser:user completion:^(PFObject *chat, NSError *error) {
                                     [self initiateChatWithObject:chat];
                                     
                                 }];
                                 
                             }];
                             
                         }];
                     });
                 }
             }];
        }
    }];
}


-(void)dismissAlertController:(UIAlertController *)controller
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
}

-(void)initiateChatWithObject: (PFObject *)chat
{

//    Needed if using tab bar:
//    chatVC.hidesBottomBarWhenPushed = YES;
    
    BOOL random = chat[PF_CHAT_RANDOM];
    
    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    chatVC.hidesBottomBarWhenPushed = YES;
    
    if (random) {
        [self performSelector:@selector(dismissAlertController:) withObject:self.alertController afterDelay:3];
        UIBarButtonItem *endChat = [[UIBarButtonItem alloc] initWithTitle:@"Leave Chat" style:UIBarButtonItemStylePlain target:self action:@selector(leaveChatButtonPressed)];
        [self.navigationController.navigationItem setRightBarButtonItem:endChat];
        [self.navigationController presentViewController:chatVC animated:YES completion:nil];
    }

    [self.navigationController pushViewController:chatVC animated:YES];
}

-(void)leaveChatButtonPressed
{
    
}

@end