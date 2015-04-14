#import "LMChatsListViewController.h"
#import "LMFriendsListView.h"
#import "LMChat.h"
#import "LMUsers.h"
#import "AppConstant.h"
#import "ChatView.h"
#import "LMChatListCell.h"
#import "LMData.h"
#import "Utility.h"
#import "LMAlertControllers.h"
#import "UIColor+applicationColors.h"
#import "LMFriendSelectionViewController.h"

#import "LMChatsModel.h"

#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface LMChatsListViewController () <LMFriendsListViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, LMRandomChatViewDelegate, LMRandomChatViewDelegate>

@property (strong, nonatomic) LMFriendsListView *chatListView;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) NSMutableDictionary *chatImages;

@property (strong, nonatomic) LMChatsModel *chatsModel;

@end

static NSString *reuseIdentifier = @"ChatCell";

@implementation LMChatsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        if (!_chatsModel) {
            _chatsModel = [[LMChatsModel alloc] init];
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
    
    UIBarButtonItem *startNewChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addChatButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:startNewChatButton];
    
    UIBarButtonItem *editChatListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableViewButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:editChatListButton];
    
    [self.chatsModel addObserver:self forKeyPath:@"chatList" options:0 context:nil];
    
    self.chatListView = [[LMFriendsListView alloc] init];
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
    
    // Download chat image to display in table cell
    PFUser *sender = chat[PF_CHAT_RECEIVER];
    NSString *senderId = sender.objectId;
    
    for (PFUser *user in chat[PF_CHAT_MEMBERS]) {
        if (user.objectId == senderId) {
            sender = user;
        }
    }
    
    if (!_chatImages) {
        _chatImages = [[NSMutableDictionary alloc] initWithCapacity:50];
    }
    
    if (![_chatImages objectForKey:chat.objectId]) {
        
        ESTABLISH_WEAK_SELF;
        PFFile *chatImage = sender[PF_USER_THUMBNAIL];
        [chatImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         
         {
             if (!error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     ESTABLISH_STRONG_SELF;
                     
                     if (strongSelf)
                     {
                         UIImage *image = [UIImage imageWithData:data];
                         [_chatImages setObject:image forKey:chat.objectId];
                         cell.chatImage = image;
                         [self.chatListView.tableView reloadData];
                     }
                 });
                 
             } else {
                 NSLog(@"There was an error retrieving profile picture");
             }
         }];
        
    } else
    {
        cell.chatImage  = [_chatImages objectForKey:chat.objectId];
    }
    
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

    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    chatVC.hidesBottomBarWhenPushed = YES;
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
        [self.chatsModel deleteChat:chat];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    footerView.backgroundColor = [UIColor nephritisColor];
    [[footerView layer] setCornerRadius:10];
    
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    footerButton.frame = footerView.frame;
    [footerButton setTitle:@"Start Chat With Random User" forState:UIControlStateNormal];
    footerButton.titleLabel.textColor = [UIColor whiteColor];
    
    [footerView addSubview:footerButton];
    
    return footerView;
}


#pragma mark - Shared Chat Objects

-(NSArray *) chats
{
    return [self.chatsModel chatList];
}

#pragma mark - Target Action Methods
-(void) addChatButtonPressed:(UIButton *)sender
{
    UIAlertController *chatTypeAlertController = [LMAlertControllers chooseChatTypeAlertWithCompletion:^(NSInteger type) {
        switch (type)
        {
            case LMChatTypeFriend:
            {
                [self presentFriendListForSelection];
                break;
            }
            case LMChatTypeGroup:
            {
                [self presentFriendListForSelection];
                break;
            }
            case LMChatTypeRandom:
            {
                [self startChatWithRandomUser];
                break;
            }
        }
    }];
    
    [self presentViewController:chatTypeAlertController animated:YES completion:nil];
}

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
        NSLog(@"stop");
        //NSNotification - begin chat with friends
    }];
    
    friendSelectionVC.title = @"Select Friends";
    [self.navigationController pushViewController:friendSelectionVC animated:YES];
}

-(void)startChatWithRandomUser
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching...", @"Searching...") maskType:SVProgressHUDMaskTypeClear];
    
    [LMUsers findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
        if (user)
        {
            PFFile *userImage = user[PF_USER_THUMBNAIL];
            
            [userImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             
             {
                 if (!error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         __block UIImageView *userPicture = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                         
                         self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"We Got One! \n Connecting With:\n", @"We Got One!")
                                                                                    message:[NSString stringWithFormat:@"%@", user.username]
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                         
                         userPicture.frame = CGRectMake(0, 0, 75, 75);
                         userPicture.contentMode = UIViewContentModeScaleAspectFill;
                         [self.alertController.view addSubview:userPicture];
                         
                         [self presentViewController:self.alertController animated:YES completion:^{
                             
                             //Need to add timer - if request times out notify user
                             
                             [[LMChat sharedInstance] startChatWithRandomUser:user completion:^(PFObject *chat, NSError *error) {
                                 [self initiate:chat withImage:userPicture];
                                 
                                 
                                 
                             }];
                             
                         }];
                     });
                 }
             }];
        }
    }];
}



-(void)initiate: (PFObject *)chat withImage:(UIImageView *)image
{
    
    //    Needed if using tab bar:
    //    chatVC.hidesBottomBarWhenPushed = YES;
    
    BOOL random = (BOOL)chat[PF_CHAT_RANDOM];
    
    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    chatVC.randomPersonPicture = image;
    chatVC.hidesBottomBarWhenPushed = YES;
    
    if (random)
    {
        [self performSelector:@selector(dismissAlertControllerAndInitiateChat:) withObject:chat afterDelay:3];
    }
        else
    {
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

-(void)dismissAlertControllerAndInitiateChat:(PFObject *)chat
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    
    ChatView *chatVC = [[ChatView alloc] initWithChat:chat];
    UINavigationController *randomChatNav = [[UINavigationController alloc] initWithRootViewController:chatVC];
    
    chatVC.delegate = self;
    chatVC.hidesBottomBarWhenPushed = YES;
    
    self.navigationController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:randomChatNav animated:YES completion:nil];
}


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


@end