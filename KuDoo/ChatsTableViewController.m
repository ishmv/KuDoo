#import "ChatsTableViewController.h"
#import "AppConstant.h"
#import "UIColor+applicationColors.h"
#import "LMTableViewCell.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "ParseConnection.h"
#import "NSArray+LanguageOptions.h"
#import "LMChatTableViewModel.h"
#import "LMNewChatViewController.h"

#import <Firebase/Firebase.h>

@interface ChatsTableViewController () <NSCoding>

@property (strong, nonatomic) NSMutableDictionary *chatViewcontrollers;
@property (strong, nonatomic) NSMutableOrderedSet *chatGroupIds;
@property (strong, nonatomic) NSMutableDictionary *chats;
@property (strong, nonatomic) NSMutableDictionary *chatImages;

//LMChatViewController Delegate containers
@property (strong, nonatomic) NSMutableDictionary *lastMessages;
@property (strong, nonatomic) NSMutableDictionary *messageCount;

@property (strong, nonatomic) Firebase *chatsFirebase;
@property (strong, nonatomic) Firebase *blocklistFirebase;
@property (nonatomic, copy, readwrite) NSString *firebasePath;
@property (strong, nonatomic) LMChatTableViewModel *viewModel;

// Contacts is a list of people the user currently has a chat with - pass in as a paramter when a new group chat is being created
@property (strong, nonatomic) NSMutableOrderedSet *contacts;
@property (strong, nonatomic) NSMutableSet *internalBlockList;

@end

@implementation ChatsTableViewController

static NSString *const reuseIdentifer = @"reuseIdentifer";

-(instancetype) initWithFirebaseAddress:(NSString *)path {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _firebasePath = path;
        [self p_configureView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont lm_robotoLightLarge]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:NSLocalizedString(@"Chats", @"Chats")];
        label;
    });
    self.navigationItem.titleView = titleLabel;
    
    self.refreshControl = ({
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(p_refreshChatImages) forControlEvents:UIControlEventValueChanged];
        refreshControl;
    });

    UIBarButtonItem *addChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(p_startNewChatPressed:)];
    self.navigationItem.rightBarButtonItem = addChatButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor lm_slateColor];
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifer];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self p_organizeChats];
    [self p_updateMessageCounters];
    self.tabBarController.hidesBottomBarWhenPushed = NO;
}

-(void)dealloc {
    [self.chatsFirebase removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatGroupIds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    }
    
    cell.cellImageViewPadding = 12.0f;
    
    cell.backgroundColor = [UIColor lm_slateColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *groupId = self.chatGroupIds[indexPath.row];
    NSDictionary *chat = [self.chats objectForKey:groupId];
    NSString *chatTitle = chat[@"title"];
    
    cell.titleLabel.text = chatTitle;
    
    if ([self.lastMessages objectForKey:groupId]) {
        NSDictionary *lastMessage = [self.lastMessages objectForKey:groupId];
        NSDate *date = [NSDate lm_stringToDate:lastMessage[@"date"]];
        NSString *text = lastMessage[@"text"];
        NSString *senderDisplayName = lastMessage[@"senderDisplayName"];
        cell.accessoryLabel.text = [NSString lm_dateToStringShortDateAndTime:date];
        
        NSString *detailText = ([senderDisplayName isEqualToString:[PFUser currentUser][PF_USER_DISPLAYNAME]]) ? [NSString stringWithFormat:@"You: %@", text] : [NSString stringWithFormat:@"%@: %@", senderDisplayName, text];
        cell.detailLabel.text = detailText;
    }
    
    if ([self.messageCount objectForKey:groupId]) {
        cell.customAccessoryLabelText =[[self.messageCount objectForKey:groupId] stringValue];
    }
    
    UIImage *chatImage = [self.chatImages objectForKey:groupId];
    
    if (!chatImage) {
        if (!_chatImages) {
            self.chatImages = [[NSMutableDictionary alloc] init];
        }
        
        if (chat[@"imageURL"] != nil) {
            [self.viewModel getImageForChat:chat withCompletion: ^(UIImage *chatImage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.cellImageView.image = chatImage;
                    [self.chatImages setObject:chatImage forKey:groupId];
                });
            }];
        } else {
            cell.cellImageView.image = [UIImage imageNamed:@"connected"];
        }
    } else {
        cell.cellImageView.image = chatImage;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.chatGroupIds.count == 0) {
        return CGRectGetHeight(self.view.frame) - 200;
    }
    
    return 0.01f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.chatGroupIds.count == 0) {
        
        UIView *noChatsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 16, CGRectGetHeight(self.view.frame) - 200)];
        
        UILabel *noChatsLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:noChatsView.frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont lm_robotoLightMessage];
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 0;
            label.text = NSLocalizedString(@"Ask people online to chat\nOr hit up forums and practice yor language with other learners", @"get started message");
            label;
        });

        [noChatsView addSubview:noChatsLabel];
        
        return noChatsView;
    }
    
    return nil;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.chatGroupIds[indexPath.row];
    [self p_createChatWithInfo:[self.chats objectForKey:key] show:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *groupId = self.chatGroupIds[indexPath.row];
        
        [self.chatGroupIds removeObjectAtIndex:indexPath.row];
        [self.chatViewcontrollers removeObjectForKey:groupId];
        [self.chats removeObjectForKey:groupId];
        [self.lastMessages removeObjectForKey:groupId];
        [self.chatsFirebase updateChildValues:@{groupId : @{}}];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }   
}

#pragma mark - Firebase Updates

-(void) updateChatsWithSnapshot:(FDataSnapshot *)snapshot
{
    if (!_chats) {
        self.chats = [[NSMutableDictionary alloc] init];
    }
    
    if (!_chatGroupIds) {
        self.chatGroupIds = [[NSMutableOrderedSet alloc] init];
    }
    
    for (FDataSnapshot *chat in snapshot.children) {
        if (![self.chats objectForKey:chat.key]) {
            [self.chatGroupIds addObject:chat.key];
            [self.chats setObject:chat.value forKey:chat.key];
            [self p_createChatWithInfo:chat.value show:NO];
            [self p_addContactsFromChat:chat.value];
            [self.tableView reloadData];
        }
    }
}

-(void) updateBlocklistWithSnapshot:(FDataSnapshot *)snapshot
{
    if (!_internalBlockList) {
        _internalBlockList = [[NSMutableSet alloc] init];
    }
    
    for (FDataSnapshot *userId in snapshot.children) {
        [_internalBlockList addObject:userId.value];
    }
}

#pragma mark - Private Methods

#pragma mark - Notifications

-(void) p_registerForChatNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_START_CHAT object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *chatInfo = note.object;
        [self p_createChatWithInfo:chatInfo show:YES];
    }];
}

-(void) p_registerForNewMessageNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *groupId = note.object;

        if ([self.chats objectForKey:groupId]) {
            [self p_createChatWithInfo:[self.chats objectForKey:groupId] show:YES];
        }
    }];
}

-(void) p_registerForBlockUserNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_BLOCK_USER object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *userToBlock = note.object;
        NSLog(@"%@", userToBlock);
        
        [self.blocklistFirebase updateChildValues:@{userToBlock : userToBlock}];
        
        Firebase *theirFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/blocklist", self.firebasePath, userToBlock]];
        [theirFirebase updateChildValues:@{[PFUser currentUser].objectId : [PFUser currentUser].objectId}];
    }];
}

#pragma mark - Private Chat
-(void) p_configureView
{
    if (!_viewModel) {
        _viewModel = [[LMChatTableViewModel alloc] initWithViewController:self];
    }
    
    [self p_registerForChatNotifications];
    [self p_registerForNewMessageNotifications];
    [self p_registerForBlockUserNotifications];
    [self p_setupFirebase];
    [self p_loadChatViewControllers];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"comment"]];
    self.tabBarItem.title = @"Chats";
}

-(void) p_loadChatViewControllers
{
    if (self.chats.count != 0) {
        for (NSString *key in self.chats) {
            NSDictionary *info = [self.chats objectForKey:key];
            [self p_createChatWithInfo:info show:NO];
        }
    }
}

-(void) p_setupFirebase
{
    self.chatsFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat: @"%@/users/%@/chats", self.firebasePath, [PFUser currentUser].objectId]];
    [self.chatsFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self updateChatsWithSnapshot:snapshot];
    }];
    
    self.blocklistFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/%@/blocklist", self.firebasePath, [PFUser currentUser].objectId]];
    [self.blocklistFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *blocklist) {
        [self updateBlocklistWithSnapshot:blocklist];
    }];
}

-(void) p_createChatWithInfo:(NSDictionary *)info show:(BOOL)present
{
    NSString *groupId = info[@"groupId"];
    
    if (!_chatViewcontrollers) {
        self.chatViewcontrollers = [[NSMutableDictionary alloc] init];
    }
    
    LMPrivateChatViewController *chatVC;
    chatVC = [self.chatViewcontrollers objectForKey:groupId];
    
    if (!chatVC) {
        chatVC = [[LMPrivateChatViewController alloc] initWithFirebaseAddress:_firebasePath andChatInfo:info];
        [self.chatViewcontrollers setObject:chatVC forKey:groupId];
    }
    
    if ([self.chatImages objectForKey:groupId]) {
        chatVC.chatImage = self.chatImages[groupId];
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Chat_Wallpaper_Index"];
    NSNumber *wallpaperSelection = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger index = [wallpaperSelection integerValue];
    UIImage *backgroundImage;
    
    if (wallpaperSelection) {
        backgroundImage = [NSArray lm_chatBackgroundImages][index];
    } else {
        backgroundImage = [UIImage imageNamed:@"auroraBorealis"];
    }
    
    chatVC.backgroundImage = backgroundImage;
    
//    Set if using background color
//    chatVC.backgroundImage = nil;
//    chatVC.backgroundColor = [UIColor lm_slateColor];
    
    chatVC.titleLabel.text = info[@"title"];
    chatVC.delegate = self;
    chatVC.hidesBottomBarWhenPushed = YES;
    
    if (present) {
        
        self.tabBarController.selectedIndex = 2;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

-(void) p_organizeChats
{
    self.chatGroupIds = [self.viewModel organizeChats:_chatGroupIds];
    [self.tableView reloadData];
}

-(void) p_refreshChatImages
{
    [self.refreshControl endRefreshing];
}

-(void) p_updateMessageCounters
{
    self.newMessageCounter = 0;
    
    for (NSString *key in self.chatViewcontrollers) {
        LMPrivateChatViewController *chatVC = [self.chatViewcontrollers objectForKey:key];
        self.newMessageCounter += chatVC.newMessageCount;
    }
    
    [self.tableView reloadData];
    
    if (self.newMessageCounter != 0) {
        [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld", (long)self.newMessageCounter]];
    } else {
        [self.tabBarItem setBadgeValue:nil];
    }
}

#pragma mark - Group Chat

-(void) p_addContactsFromChat:(NSDictionary *)chat
{
    if (!_contacts) {
        self.contacts = [[NSMutableOrderedSet alloc] init];
    }

    NSArray *members = chat[@"members"];
    
    [ParseConnection searchForUserIds:members withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
        [self.contacts addObjectsFromArray:objects];
    }];
}


-(void) p_startNewChatPressed:(UIBarButtonItem *)sender
{
    LMNewChatViewController *newChat = [[LMNewChatViewController alloc] initWithContacts:self.contacts];
    [self.navigationController pushViewController:newChat animated:YES];
}

#pragma mark - LMChatViewControllerDelegate

-(void) updateLastMessage:(NSDictionary *)message forChatViewController:(LMChatViewController *)controller
{
    if (!_lastMessages) {
        self.lastMessages = [[NSMutableDictionary alloc] init];
    }
    
    [self.lastMessages setObject:message forKey:controller.groupId];
    [self p_organizeChats];
}

-(void) incrementNewMessageCount:(NSInteger)messageCount forChatViewController:(LMChatViewController *)controller
{
    if (!_messageCount) {
        self.messageCount = [[NSMutableDictionary alloc] init];
    }
    
    [self.messageCount setObject:@(messageCount) forKey:controller.groupId];
    [self p_updateMessageCounters];
}

#pragma mark - Getter Methods

-(NSDictionary *)lastSentMessages {
    return [self.lastMessages copy];
}

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.chats = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chats))];
        self.lastMessages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lastMessages))];
        self.messageCount = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messageCount))];
        self.chatViewcontrollers = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatViewcontrollers))];
        self.chatGroupIds = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatGroupIds))];
        self.firebasePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebasePath))];
        self.chatImages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatImages))];
        
    } else {
        return nil;
    }
    
    for (NSString *key in self.chats) {
        [self p_addContactsFromChat:self.chats[key]];
    }
    
    [self p_configureView];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.chats forKey:NSStringFromSelector(@selector(chats))];
    [aCoder encodeObject:self.lastMessages forKey:NSStringFromSelector(@selector(lastMessages))];
    [aCoder encodeObject:self.messageCount forKey:NSStringFromSelector(@selector(messageCount))];
    [aCoder encodeObject:self.chatGroupIds forKey:NSStringFromSelector(@selector(chatGroupIds))];
    [aCoder encodeObject:self.chatViewcontrollers forKey:NSStringFromSelector(@selector(chatViewcontrollers))];
    [aCoder encodeObject:self.firebasePath forKey:NSStringFromSelector(@selector(firebasePath))];
    [aCoder encodeObject:self.chatImages forKey:NSStringFromSelector(@selector(chatImages))];
}

@end