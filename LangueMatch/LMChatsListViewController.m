#import "LMChatsListViewController.h"
#import "LMChatDetailsViewController.h"
#import "LMFriendSelectionViewController.h"

#import "LMListView.h"
#import "LMFriendsModel.h"
#import "LMChatViewController.h"
#import "LMRandomChatViewController.h"
#import "LMChatListCell.h"

#import "LMChatFactory.h"
#import "AppConstant.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMChatsModel.h"
#import "LMParseConnection+Chats.h"
#import "LMGlobalVariables.h"

#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface LMChatsListViewController () <LMListViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, LMChatViewControllerDelegate>

@property (strong, nonatomic) LMListView *chatListView;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) LMChatsModel *chatsModel;

@property (strong, nonatomic) NSMutableDictionary *chatViewControllers;

@end

static NSString *reuseIdentifier = @"ChatCell";

@implementation LMChatsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        if (!_chatsModel) {
            _chatsModel = [[LMChatsModel alloc] init];
            [self registerForNewMessageNotifications];
        }
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"comment.png"] tag:1];
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.chatListView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_chatViewControllers) {
        _chatViewControllers = [NSMutableDictionary new];
        
        for (PFObject *chat in self.chatsModel.chatList)
        {
            [self p_getViewControllerForChat:chat];
        }
    }
    
    [self p_renderBackgroundLayer];
    
    UIBarButtonItem *startNewChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(presentFriendListForSelection)];
    [self.navigationItem setRightBarButtonItem:startNewChatButton];
    
    UIBarButtonItem *editChatListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableViewButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:editChatListButton];
    
    [self.chatsModel addObserver:self forKeyPath:@"chatList" options:0 context:nil];
    
    self.chatListView = [[LMListView alloc] init];
    self.chatListView.delegate = self;
    [self.chatListView.tableView registerClass:[LMChatListCell class] forCellReuseIdentifier:reuseIdentifier];
   
    [self.view addSubview:self.chatListView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.chatListView.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [self.chatsModel removeObserver:self forKeyPath:@"chatList"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NOTIFICATION_RECEIVED_NEW_MESSAGE];
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
    LMChatViewController *chatVC = [self p_getViewControllerForChat:chat];
    [self.navigationController pushViewController:chatVC animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PFObject *chat = [self chats][indexPath.row];
        NSString *groupId = chat[PF_CHAT_GROUPID];
        [self.chatViewControllers removeObjectForKey:groupId];
        [self.chatsModel deleteChat:chat];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    headerView.backgroundColor = [UIColor lm_lightYellowColor];
    
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    footerButton.frame = headerView.frame;
    [footerButton setTitle:@"> Find Random LangueMatch User" forState:UIControlStateNormal];
    footerButton.titleLabel.textColor = [UIColor whiteColor];
    footerButton.titleLabel.font = [UIFont lm_noteWorthyMedium];
    [footerButton addTarget:self action:@selector(startRandomChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:footerButton];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    
    return footerView;
}

#pragma mark - Shared Chat Objects

-(NSArray *) chats
{
    return [self.chatsModel chatList];
}

#pragma mark - Touch Handling

-(void) editTableViewButtonPressed:(UIButton *)sender
{
    if (self.chatListView.tableView.isEditing) {
        [self.chatListView.tableView setEditing:NO animated:YES];
    } else {
        [self.chatListView.tableView setEditing:YES animated:YES];
    }
}

-(void) presentFriendListForSelection
{
    LMFriendSelectionViewController *friendSelectionVC = [[LMFriendSelectionViewController alloc] initWithCompletion:^(NSArray *friends) {
    
        if (friends.count > 1)
        {
            LMChatDetailsViewController *chatDeetsVC = [[LMChatDetailsViewController alloc] initWithCompletion:^(NSDictionary *chatDetails) {
                [self startChatWithFriends:friends andOptions:chatDetails];
            }];
            
            chatDeetsVC.title = @"Chat Deets";
            [self.navigationController pushViewController:chatDeetsVC animated:YES];
            
        } else {
            [self startChatWithFriends:friends andOptions:nil];
        }
    }];
    
    friendSelectionVC.title = @"Select Friends";
    [self.navigationController pushViewController:friendSelectionVC animated:YES];
}


-(void)startChatWithFriends:(NSArray *)friends andOptions:(NSDictionary *)options
{
    PFUser *currentUser = [PFUser currentUser];
    
    [LMChatFactory createChatForUser:currentUser withMembers:friends chatDetails:options andCompletion:^(PFObject *chat, NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"There was an error starting the chat", @"There was an error starting the chat")];
        }
        else
        {
            LMChatViewController *chatVC = [self p_getViewControllerForChat:chat];
            [self.navigationController setViewControllers:@[self, chatVC] animated:YES];
        }
    }];
}

#pragma mark - Random Chat

-(void) startRandomChatButtonPressed:(UIButton *)sender
{
    //Check if network connection first!
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching...", @"Searching...") maskType:SVProgressHUDMaskTypeClear];
    
    [LMParseConnection findRandomUserForChatWithCompletion:^(PFUser *user, UIImage *userImage, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        if (!error)
        {
            alert.title = NSLocalizedString(@"We Found One!\n Connecting With:\n", @"Found Chat Partner");
            alert.message = [NSString stringWithFormat:@"%@", user.username];
            
            UIImageView *userImageView = [[UIImageView alloc] initWithImage:userImage];
            userImageView.frame = CGRectMake(0, 0, 75, 75);
            userImageView.contentMode = UIViewContentModeScaleAspectFill;
            [alert.view addSubview:userImageView];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertAction *startChatAction = [UIAlertAction actionWithTitle:@"Say Hi >" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSDictionary *chatDetails = @{PF_CHAT_RANDOM : @(YES)};
                [LMChatFactory createChatForUser:[PFUser currentUser] withMembers:@[user] chatDetails:chatDetails andCompletion:^(PFObject *chat, NSError *error) {
                    LMRandomChatViewController *randomChatVC = [[LMRandomChatViewController alloc] initWithChat:chat];
                    randomChatVC.hidesBottomBarWhenPushed = YES;
                    randomChatVC.title = chat[PF_CHAT_TITLE];
                    randomChatVC.delegate = self;
                    [self.navigationController pushViewController:randomChatVC animated:YES];
                }];
            }];
            
            [alert addAction:cancelAction];
            [alert addAction:startChatAction];
        }
        
        else if (error.code == TBParseError_ObjectNotFound)
        {
            alert.title = NSLocalizedString(@"Our apologies...", @"No One available");
            alert.message = NSLocalizedString(@"It appears no one is available to chat now\n please try again later", @"Try Again Later");
        }
        
        [SVProgressHUD dismiss];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}


#pragma mark - Chat View Delegate

-(void) endedRandom:(PFObject *)chat
{
    //ToDo Delete and ask if they would like to be friends
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Key/Value Observing

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"chatList"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.chatListView.tableView reloadData];
            
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
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
            [self.chatListView.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.chatListView.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.chatListView.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.chatListView.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.chatListView.tableView endUpdates];
        }
    }
}

#pragma mark - LMChatViewController Delegate

-(void)userEndedChat:(PFObject *)chat
{
    if (![chat[PF_CHAT_RANDOM] boolValue])
    {
        if (!chat.objectId)
        {
            [self.chatsModel deleteChat:chat];
            [self.chatViewControllers removeObjectForKey:chat[PF_CHAT_GROUPID]];
        }
    }
    else
    {
        // Ask user to rate chat partner
        NSLog(@"Ended Random Chat");
    }
}

-(void) lastMessage:(PFObject *)message forChat:(PFObject *)chat
{
    NSInteger index = [[self chats] indexOfObject:chat];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    LMChatListCell *cell = (LMChatListCell *)[self.chatListView.tableView cellForRowAtIndexPath:indexPath];
    cell.lastMessage = message;
    [self.chatListView.tableView reloadData];
}

#pragma mark - Notifications

-(void) registerForNewMessageNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        PFObject *message = note.object;
        PFObject *chat = message[PF_CHAT_CLASS_NAME];
        
        LMChatViewController *chatVC = [self p_getViewControllerForChat:chat];
        [chatVC receivedNewMessage:message];
        
        NSInteger appState = [[UIApplication sharedApplication] applicationState];
        if (appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
            [self.navigationController setViewControllers:@[self, chatVC] animated:YES];
        }
    }];
}

#pragma mark - Private Methods

-(LMChatViewController *) p_getViewControllerForChat:(PFObject *)chat
{
    NSString *groupId = chat[PF_CHAT_GROUPID];
    LMChatViewController *chatVC;
    
    if (![self.chatsModel.chatList containsObject:chat])
    {
        [self.chatsModel addChat:chat];
    }
    
    if ([self.chatViewControllers objectForKey:groupId])
    {
        chatVC = self.chatViewControllers[groupId];
    }
    else
    {
        chatVC = [[LMChatViewController alloc] initWithChat:chat];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.title = chat[PF_CHAT_TITLE];
        chatVC.delegate = self;
        [self.chatViewControllers setObject:chatVC forKey:chat[PF_CHAT_GROUPID]];
    }
    return chatVC;
}

-(void) p_renderBackgroundLayer
{
    self.view.backgroundColor = [UIColor clearColor];
    CALayer *layer = [LMGlobalVariables universalBackgroundColor];
    layer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view.layer addSublayer:layer];    
}

@end