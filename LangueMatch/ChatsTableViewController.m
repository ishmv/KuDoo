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

// Testing for Group Chat
#import "LMNewChatViewController.h"

#import <Firebase/Firebase.h>

@interface ChatsTableViewController () <NSCoding>

@property (strong, nonatomic) NSMutableDictionary *chatViewcontrollers;
@property (strong, nonatomic) NSMutableOrderedSet *chatGroupIds;
@property (strong, nonatomic) NSMutableDictionary *chats;

//Stores a groupId as the key with the chats corresponding last message. Used to update table view order
@property (strong, nonatomic) NSMutableDictionary *lastMessages;
@property (strong, nonatomic) NSMutableDictionary *messageCount;

@property (nonatomic, assign) NSInteger newMessageCounter;

@property (strong, nonatomic) Firebase *chatsFirebase;
@property (nonatomic, copy, readwrite) NSString *firebasePath;
@property (strong, nonatomic) LMChatTableViewModel *viewModel;

//Stores each contact - testing for group chat
@property (strong, nonatomic) NSMutableOrderedSet *contacts;

@end

@implementation ChatsTableViewController

static NSString *const reuseIdentifer = @"reuseIdentifer";

-(instancetype) initWithFirebaseAddress:(NSString *)path
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _firebasePath = path;
        [self p_configureView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_robotoLightLarge]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Chats", @"Chats")];
    [self.navigationItem setTitleView:titleLabel];
    
    UIBarButtonItem *addChatButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(p_startNewChatPressed:)];
    self.navigationItem.rightBarButtonItem = addChatButton;

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 15);
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_organizeChats];
    [self p_updateMessageCounters];
}

-(void)dealloc
{
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
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *key = self.chatGroupIds[indexPath.row];
    
    if ([self.lastMessages objectForKey:key]) {
        NSDictionary *lastMessage = [self.lastMessages objectForKey:key];
        NSDate *date = [NSDate lm_stringToDate:lastMessage[@"date"]];
        NSString *text = lastMessage[@"text"];
        NSString *senderDisplayName = lastMessage[@"senderDisplayName"];
        cell.accessoryLabel.text = [NSString lm_dateToStringShortDateAndTime:date];
        
        NSString *detailText = ([senderDisplayName isEqualToString:[PFUser currentUser][PF_USER_DISPLAYNAME]]) ? [NSString stringWithFormat:@"You: %@", text] : [NSString stringWithFormat:@"%@: %@", senderDisplayName, text];
        cell.detailLabel.text = detailText;
    }
    
    if ([self.messageCount objectForKey:key]) {
        if ([[self.messageCount objectForKey:key] intValue] != 0) {
            [cell.customAccessoryView.layer setCornerRadius:12.5f];
            [cell.customAccessoryView.layer setMasksToBounds:YES];
            cell.customAccessoryView.textAlignment = NSTextAlignmentCenter;
            cell.customAccessoryView.backgroundColor = [UIColor whiteColor];
            cell.customAccessoryView.textColor = [UIColor lm_wetAsphaltColor];
            cell.customAccessoryView.font = [UIFont lm_robotoLightTimestamp];
            cell.customAccessoryView.text = [[self.messageCount objectForKey:key] stringValue];
        } else {
            cell.customAccessoryView.text = @"";
            cell.customAccessoryView.backgroundColor = [UIColor clearColor];
        }
    }
    
    [cell.cellImageView.layer setMasksToBounds:YES];
    [cell.cellImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.cellImageView.layer setBorderWidth:2.0f];
    
    NSDictionary *chat = [self.chats objectForKey:key];
    NSString *chatTitle = chat[@"title"];
    
    cell.titleLabel.text = chatTitle;
    
    if ([chat[@"member"] isKindOfClass:[NSArray class]]) {
        [self.viewModel getChatImage:chat[@"image"] forGroupId:key withCompletion:^(UIImage *image, NSError *error) {
            cell.cellImageView.image = image;
        }];
    } else {
        [self.viewModel getUserThumbnail:chat[@"member"] withCompletion:^(UIImage *image, NSError *error) {
            cell.cellImageView.image = image;
        }];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
        
        UIView *noChatsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 200)];
        
        UILabel *noChatsLabel = [[UILabel alloc] initWithFrame:noChatsView.frame];
        noChatsLabel.textAlignment = NSTextAlignmentCenter;
        noChatsLabel.font = [UIFont lm_noteWorthyMedium];
        noChatsLabel.numberOfLines = 0;
        noChatsLabel.text = NSLocalizedString(@"Ask people online to chat\nOr hit up forums and practice yor language with other learners", @"get started message");
        [noChatsView addSubview:noChatsLabel];
        
        return noChatsView;
    }
    
    return nil;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.chatGroupIds[indexPath.row];
    [self p_createChatWithGroupId:key andInfo:[self.chats objectForKey:key] present:YES];
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

#pragma mark - Notifications

-(void) p_registerForChatNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_START_CHAT object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *chatInfo = note.object;
        [self p_createChatWithGroupId:chatInfo[@"groupId"] andInfo:chatInfo present:YES];
    }];
}

-(void) p_registerForNewMessageNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_RECEIVED_NEW_MESSAGE object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *groupId = note.object;
        
        LMPrivateChatViewController *chatVC = [self.chatViewcontrollers objectForKey:groupId];
        self.tabBarController.selectedViewController = self.navigationController;
        [self.navigationController setViewControllers:@[self, chatVC] animated:YES];
    }];
}

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {

    self.chats = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chats))];
    self.lastMessages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lastMessages))];
    self.chatViewcontrollers = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatViewcontrollers))];
    self.chatGroupIds = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatGroupIds))];
    self.firebasePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebasePath))];
    self.viewModel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(viewModel))];
        
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
    [aCoder encodeObject:self.chatGroupIds forKey:NSStringFromSelector(@selector(chatGroupIds))];
    [aCoder encodeObject:self.chatViewcontrollers forKey:NSStringFromSelector(@selector(chatViewcontrollers))];
    [aCoder encodeObject:self.firebasePath forKey:NSStringFromSelector(@selector(firebasePath))];
    [aCoder encodeObject:self.viewModel forKey:NSStringFromSelector(@selector(viewModel))];
}

#pragma mark - Private Methods
-(void) p_configureView
{
    if (!_viewModel) {
        _viewModel = [[LMChatTableViewModel alloc] initWithViewController:self];
    }
    
    [self p_registerForChatNotifications];
    [self p_registerForNewMessageNotifications];
    [self p_setupFirebase];
    [self p_loadChatViewControllers];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"comment"]];
    self.tabBarItem.title = @"Chats";
}


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
            [self p_addContactsFromChat:chat.value];
            [self.tableView reloadData];
        }
    }
}

-(void) p_loadChatViewControllers
{
    if (self.chats.count != 0) {
        for (NSString *key in self.chats) {
            NSDictionary *info = [self.chats objectForKey:key];
            [self p_createChatWithGroupId:key andInfo:info present:NO];
        }
    }
}

-(void) p_setupFirebase
{
    [self.viewModel setupFirebaseWithAddress:self.firebasePath forUser:[PFUser currentUser].objectId];
    self.chatsFirebase = self.viewModel.firebase;
}

-(void) p_createChatWithGroupId:(NSString *)groupId andInfo:(NSDictionary *)info present:(BOOL)present
{
    if (!_chatViewcontrollers) {
        self.chatViewcontrollers = [[NSMutableDictionary alloc] init];
    }
    
    LMPrivateChatViewController *chatVC;
    chatVC = [self.chatViewcontrollers objectForKey:groupId];
    
    if (!chatVC) {
        chatVC = [[LMPrivateChatViewController alloc] initWithFirebaseAddress:_firebasePath groupId:groupId andChatInfo:info];
        [self.chatViewcontrollers setObject:chatVC forKey:groupId];
    }
    

    if ([info[@"member"] isKindOfClass:[NSArray class]]) {
        [self.viewModel getChatImage:info[@"image"] forGroupId:groupId withCompletion:^(UIImage *image, NSError *error) {
            chatVC.chatImage = image;
        }];
    } else {
        [self.viewModel getUserPicture:info[@"member"] withCompletion:^(UIImage *image, NSError *error) {
            chatVC.chatImage = image;
        }];
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
    chatVC.chatTitle = info[@"title"];
    chatVC.delegate = self;
    chatVC.hidesBottomBarWhenPushed = YES;
    
    if (present) {
        self.tabBarController.selectedViewController = self.navigationController;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

-(void) p_organizeChats
{
    self.chatGroupIds = [self.viewModel organizeChats:_chatGroupIds];
    [self.tableView reloadData];
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



/*
 
 Group Chat
 
 */

// --------- --------------- --------------

// Collects list of users the currentuser is chatting with. A pseudo friends list

-(void) p_addContactsFromChat:(NSDictionary *)chat
{
    if (!_contacts) {
        self.contacts = [[NSMutableOrderedSet alloc] init];
    }

    NSArray *members = chat[@"member"];
    
    if ([chat[@"member"] isKindOfClass:[NSArray class]]) {
        members = chat[@"member"];
    } else {
         members = @[chat[@"member"]];
    }
    
    [ParseConnection searchForUserIds:members withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
        [self.contacts addObjectsFromArray:objects];
    }];
}


-(void) p_startNewChatPressed:(UIBarButtonItem *)sender
{
    LMNewChatViewController *newChat = [[LMNewChatViewController alloc] initWithContacts:self.contacts];
    [self.navigationController pushViewController:newChat animated:YES];
}


// ---------- ------------- ---------------

#pragma mark - LMChatViewControllerDelegate

-(void)lastMessage:(NSDictionary *)lastMessage forChat:(NSString *)groupId
{
    if (!_lastMessages) {
        self.lastMessages = [[NSMutableDictionary alloc] init];
    }
    
    [self.lastMessages setObject:lastMessage forKey:groupId];
    [self p_organizeChats];
}

-(void) incrementedNewMessageCount:(NSInteger)messageCount ForChat:(NSString *)groupId
{
    if (!_messageCount) {
        self.messageCount = [[NSMutableDictionary alloc] init];
    }
    
    [self.messageCount setObject:@(messageCount) forKey:groupId];
    [self p_updateMessageCounters];
}

#pragma mark - Getter Methods

-(NSDictionary *)lastSentMessages
{
    return [self.lastMessages copy];
}


@end
