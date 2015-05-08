#import "LMChatsListViewController.h"
#import "LMChatDetailsViewController.h"
#import "LMFriendSelectionViewController.h"

#import "LMListView.h"
#import "LMChatViewController.h"
#import "LMChatListCell.h"

#import "LMChatFactory.h"
#import "AppConstant.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMChatsModel.h"
#import "LMParseConnection.h"

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
            [self getViewControllerForChat:chat];
        }
    }
    
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
    LMChatViewController *chatVC = [self getViewControllerForChat:chat];
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
    headerView.backgroundColor = [UIColor lm_peterRiverColor];
    
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    footerButton.frame = headerView.frame;
    [footerButton setTitle:@"Find Random LangueMatch User" forState:UIControlStateNormal];
    footerButton.titleLabel.textColor = [UIColor whiteColor];
    footerButton.titleLabel.font = [UIFont lm_applicationFontLarge];
    [footerButton addTarget:self action:@selector(startChatWithRandomUser) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - Target Action Methods

-(void) editTableViewButtonPressed:(UIButton *)sender
{
    if (self.chatListView.tableView.isEditing) {
        [self.chatListView.tableView setEditing:NO animated:YES];
    } else {
        [self.chatListView.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - Random Chat

-(void) presentFriendListForSelection
{
    LMFriendSelectionViewController *friendSelectionVC = [[LMFriendSelectionViewController alloc] initWithStyle:UITableViewStylePlain withCompletion:^(NSArray *friends) {
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
            LMChatViewController *chatVC = [self getViewControllerForChat:chat];
            [self.navigationController setViewControllers:@[self, chatVC] animated:YES];
        }
    }];
}

-(void)startChatWithRandomUser
{
    [SVProgressHUD showErrorWithStatus:@"Random Chat Functionality currently down!" maskType:SVProgressHUDMaskTypeClear];
    
    
    
//    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching...", @"Searching...") maskType:SVProgressHUDMaskTypeClear];
    
//    [LMUsers findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
//        if (user)
//        {
//            PFFile *userImage = user[PF_USER_THUMBNAIL];
//            
//            [userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
//             
//             {
//                 if (!error) {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         __block UIImageView *userPicture = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
//                         
//                         self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"We Got One! \n Connecting With:\n", @"We Got One!")
//                                                                                    message:[NSString stringWithFormat:@"%@", user.username]
//                                                                             preferredStyle:UIAlertControllerStyleAlert];
//                         
//                         userPicture.frame = CGRectMake(0, 0, 75, 75);
//                         userPicture.contentMode = UIViewContentModeScaleAspectFill;
//                         [self.alertController.view addSubview:userPicture];
//                         
//                         [self presentViewController:self.alertController animated:YES completion:^{
//                             
//                             //Need to add timer - if request times out notify user
//                             
//                             [LMChat startChatWithRandomUser:user completion:^(PFObject *chat, NSError *error) {
//                                 [self initiate:chat withImage:userPicture];
//                                 
//                             }];
//                             
//                         }];
//                     });
//                 }
//             }];
//        }
//    }];
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
    if (!chat.objectId) {
        [self.chatsModel deleteChat:chat];
        [self.chatViewControllers removeObjectForKey:chat[PF_CHAT_GROUPID]];
    } else {
//        [self.chatsModel update];
    }
}


#pragma mark - Notifications

-(void) registerForNewMessageNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        PFObject *message = note.object;
        PFObject *chat = message[PF_CHAT_CLASS_NAME];
        
        LMChatViewController *chatVC = [self getViewControllerForChat:chat];
        [chatVC receivedNewMessage:message];
        
        NSInteger appState = [[UIApplication sharedApplication] applicationState];
        if (appState == UIApplicationStateBackground || appState == UIApplicationStateInactive) {
            [self.navigationController setViewControllers:@[self, chatVC] animated:YES];
        }
    }];
}

#pragma mark - Helper Methods

-(LMChatViewController *) getViewControllerForChat:(PFObject *)chat
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

@end