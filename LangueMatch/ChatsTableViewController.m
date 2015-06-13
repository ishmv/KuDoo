#import "ChatsTableViewController.h"
#import "AppConstant.h"
#import "LMPrivateChatViewController.h"
#import "UIColor+applicationColors.h"
#import "LMTableViewCell.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"
#import "Utility.h"
#import "ParseConnection.h"
#import "LMChatTableViewModel.h"

#import <Firebase/Firebase.h>

@interface ChatsTableViewController () <NSCoding, LMChatViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *chatViewcontrollers;
@property (strong, nonatomic) NSMutableOrderedSet *chatGroupIds;
@property (strong, nonatomic) NSMutableDictionary *chats;

//Stores a groupId as the key with the chats corresponding last message. Used to update table view order
@property (strong, nonatomic) NSMutableDictionary *lastMessages;
@property (strong, nonatomic) NSMutableDictionary *chatThumbnails;
@property (strong, nonatomic) NSMutableDictionary *messageCount;

@property (nonatomic, assign) NSInteger newMessageCounter;

@property (strong, nonatomic) Firebase *chatsFirebase;
@property (nonatomic, copy, readwrite) NSString *firebasePath;
@property (strong, nonatomic) LMChatTableViewModel *viewModel;

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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    NSString *key = self.chatGroupIds[indexPath.row];
    
    if ([self.lastMessages objectForKey:key]) {
        NSDictionary *lastMessage = [self.lastMessages objectForKey:key];
        NSDate *date = [NSDate lm_stringToDate:lastMessage[@"date"]];
        NSString *text = lastMessage[@"text"];
        NSString *senderDisplayName = lastMessage[@"senderDisplayName"];
        cell.accessoryLabel.text = [NSString lm_dateToStringShort:date];
        
        NSString *detailText = ([senderDisplayName isEqualToString:[PFUser currentUser].username]) ? [NSString stringWithFormat:@"You: %@", text] : [NSString stringWithFormat:@"%@: %@", senderDisplayName, text];
        cell.detailLabel.text = detailText;
    }
    
    if ([self.messageCount objectForKey:key]) {
        if ([[self.messageCount objectForKey:key] intValue] != 0) {
            UILabel *accessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            cell.accessoryView = accessoryView;
            [accessoryView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [accessoryView.layer setBorderWidth:2.0f];
            [accessoryView.layer setCornerRadius:15.0f];
            [accessoryView.layer setMasksToBounds:YES];
            accessoryView.textAlignment = NSTextAlignmentCenter;
            accessoryView.backgroundColor = [UIColor lm_orangeColor];
            accessoryView.textColor = [UIColor lm_wetAsphaltColor];
            accessoryView.text = [[self.messageCount objectForKey:key] stringValue];
        } else {
            cell.accessoryView = nil;
        }
    }
    
    NSDictionary *chat = [self.chats objectForKey:key];
    NSString *chatTitle = chat[@"title"];
    NSString *userId = chat[@"member"];
    
    cell.titleLabel.text = chatTitle;
    cell.cellImageView.image = [self p_getUserThumbnail:userId];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
        [self.chatThumbnails removeObjectForKey:groupId];
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

#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {

    self.chats = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chats))];
    self.lastMessages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lastMessages))];
    self.chatThumbnails = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatThumbnails))];
    self.chatViewcontrollers = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatViewcontrollers))];
    self.chatGroupIds = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatGroupIds))];
    self.firebasePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firebasePath))];
        
    } else {
        return nil;
    }
    
    [self p_configureView];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.chats forKey:NSStringFromSelector(@selector(chats))];
    [aCoder encodeObject:self.lastMessages forKey:NSStringFromSelector(@selector(lastMessages))];
    [aCoder encodeObject:self.chatThumbnails forKey:NSStringFromSelector(@selector(chatThumbnails))];
    [aCoder encodeObject:self.chatGroupIds forKey:NSStringFromSelector(@selector(chatGroupIds))];
    [aCoder encodeObject:self.chatViewcontrollers forKey:NSStringFromSelector(@selector(chatViewcontrollers))];
}

#pragma mark - Private Methods
-(void) p_configureView
{
     _viewModel = [[LMChatTableViewModel alloc] initWithViewController:self];
    
    [self p_registerForChatNotifications];
    [self p_setupFirebase];
    [self p_loadChatViewControllers];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"comment.png"]];
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
        chatVC = [[LMPrivateChatViewController alloc] initWithFirebaseAddress:[NSString stringWithFormat:@"%@/chats", self.firebasePath] groupId:groupId andChatInfo:info];
        [self.chatViewcontrollers setObject:chatVC forKey:groupId];
    }
    
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

-(UIImage *) p_getUserThumbnail:(NSString *)userId
{
    return [self.viewModel getUserThumbnail:userId];
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

@end
