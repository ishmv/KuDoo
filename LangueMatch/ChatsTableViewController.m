//
//  ChatsTableViewController.m
//  friendChat
//
//  Created by Travis Buttaccio on 6/1/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "ChatsTableViewController.h"
#import "AppConstant.h"
#import "LMPrivateChatViewController.h"
#import "LMFirebaseViewController.h"
#import "UIColor+applicationColors.h"
#import "LMTableViewCell.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>

#define kFirebaseUsersAddress @"https://langMatch.firebaseio.com/users/"
#define kFirebaseChatsAddress @"https://langMatch.firebaseio.com/chats/"

@interface ChatsTableViewController () <NSCoding, LMChatViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *chatViewcontrollers;
@property (strong, nonatomic) NSMutableOrderedSet *dictionaryKeys;
@property (strong, nonatomic) NSMutableDictionary *chats;

@property (strong, nonatomic) NSString *archivePath;

@property (strong, nonatomic) LMFirebaseViewController *requestsVC;

@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) Firebase *chatsFirebase;

@end

@implementation ChatsTableViewController

static NSString *const reuseIdentifer = @"reuseIdentifer";

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        [self p_registerForLogoutNotifications];

        [self.tabBarItem setImage:[UIImage imageNamed:@"comment.png"]];
        self.tabBarItem.title = @"Chats";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *requestsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"follow"] style:UIBarButtonItemStylePlain target:self action:@selector(chatRequestsButtonPressed:)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = requestsButton;
    
    [[self.navigationController tabBarItem] setBadgeValue:@"1"];
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self p_archiveChats];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    return self.dictionaryKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    }
    
    cell.backgroundColor = [UIColor lm_slateColor];
    
    NSString *key = self.dictionaryKeys[indexPath.row];
    NSDictionary *snapshot = [self.chats objectForKey:key];
    NSDictionary *chat = snapshot[key];
    NSString *chatTitle = chat[@"title"];
    
    cell.titleLabel.text = chatTitle;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.dictionaryKeys[indexPath.row];
    [self p_startChatWithGroupId:key];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Private Methods
-(void) p_updateChatsWithSnapshot:(FDataSnapshot *)snapshot
{
    if (!_chats) {
        self.chats = [[NSMutableDictionary alloc] init];
    }
    
    if (!_dictionaryKeys) {
        self.dictionaryKeys = [[NSMutableOrderedSet alloc] init];
    }
    
    for (FDataSnapshot *chat in snapshot.children) {
        if (![self.chats objectForKey:chat.key]) {
            [self.dictionaryKeys addObject:chat.key];
            [self.chats setObject:snapshot.value forKey:chat.key];
            [self.tableView reloadData];
        }
    }
}

-(void) p_setupFirebase
{
    self.chatsFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat: @"%@%@/chats", kFirebaseUsersAddress, [PFUser currentUser].objectId]];
    
    [self.chatsFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self p_updateChatsWithSnapshot:snapshot];
    }];
}

-(void) p_startChatWithGroupId:(NSString *)groupId
{
    if (!_chatViewcontrollers) {
        self.chatViewcontrollers = [[NSMutableDictionary alloc] init];
    }
    
    LMPrivateChatViewController *chatVC;
    chatVC = [self.chatViewcontrollers objectForKey:groupId];
    
    if (!chatVC) {
        chatVC = [[LMPrivateChatViewController alloc] initWithFirebaseAddress:kFirebaseChatsAddress andGroupId:groupId];
        [self.chatViewcontrollers setObject:chatVC forKey:groupId];
        chatVC.delegate = self;
        chatVC.hidesBottomBarWhenPushed = YES;
    }
    
    self.tabBarController.selectedViewController = self.navigationController;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - Notifications

-(void) p_registerForLogoutNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_USER_LOGGED_OUT object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self p_deleteChatArchive];
    }];
}

#pragma mark - Keyed Archiving

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.chats = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chats))];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.chats forKey:NSStringFromSelector(@selector(chats))];
}

-(void) p_archiveChats
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!_archivePath) {
            self.archivePath = [NSString lm_pathForFilename:NSStringFromSelector(@selector(chats))];
        }
        
        NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:self.chats];
        
        NSError *dataError;
        BOOL wroteSuccessfully = [mediaItemData writeToFile:_archivePath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
    });
}

-(void) p_decodeChats
{
    if (_chats != nil) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [NSString lm_pathForFilename:NSStringFromSelector(@selector(chats))];
        NSDictionary *storedChats = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *archivedChats = [storedChats mutableCopy];
            self.chats = archivedChats;
            self.dictionaryKeys = [[NSMutableOrderedSet alloc] initWithArray:self.chats.allKeys];
            [self.tableView reloadData];
            
            [self p_setupFirebase];
            
        });
    });
}

-(void)p_deleteChatArchive
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:self.archivePath error:&error];
    if (!success) {
        NSLog(@"There was a problem delete the archived chats");
    }
}

#pragma mark - LMChatViewControllerDelegate

-(void)lastMessage:(NSDictionary *)lastMessage forChat:(NSString *)groupId
{
//    NSString *type = lastMessage[@"type"];
//    NSDate *date = [NSDate lm_stringToDate:lastMessage[@"date"]];
//    NSString *text = lastMessage[@"text"];
//    NSString *senderId = lastMessage[@"senderId"];
//    NSString *senderDisplayName = lastMessage[@"senderDisplayName"];
}

#pragma mark - Touch Handling

-(void)chatRequestsButtonPressed:(UIBarButtonItem *)sender
{
    if (!_requestsVC) {
        self.requestsVC = [[LMFirebaseViewController alloc] initWithFirebase:[NSString stringWithFormat:@"%@%@/requests", kFirebaseUsersAddress, [PFUser currentUser].objectId]];
        self.requestsVC.title = @"Requests";
    }
    
    self.requestsVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:self.requestsVC animated:YES];
}


@end
