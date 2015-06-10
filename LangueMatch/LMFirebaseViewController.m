#import "LMFirebaseViewController.h"
#import "LMPrivateChatViewController.h"
#import "LMTableViewCell.h"
#import "NSString+Chats.h"
#import "UIColor+applicationColors.h"
#import "AppConstant.h"
#import "Utility.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Firebase/Firebase.h>
#import "ParseConnection.h"

#define kFirebaseChatsAddress @"https://langMatch.firebaseio.com/chats/"

@interface LMFirebaseViewController ()

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableDictionary *userThumbnails;
@property (nonatomic, strong) NSMutableArray *users;

@property (strong, nonatomic) Firebase *firebase;

@end

@implementation LMFirebaseViewController

static NSString *reuseIdentifier = @"reuseIdentifier";

-(instancetype) initWithFirebase:(NSString *)path
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _firebasePath = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self p_setupFirebase];
}

-(void) dealloc
{
    [self.firebase removeAllObservers];
    
    self.userThumbnails = nil;
    self.requests = nil;
    self.users = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.backgroundColor = [UIColor lm_wetAsphaltColor];
    
    PFUser *user = self.users[indexPath.row];
    NSDictionary *request = self.requests[user.objectId];
    
    cell.titleLabel.text = user.username;
    cell.detailLabel.text = [NSString stringWithFormat:@"Request sent on %@", request[@"date"]];
    cell.cellImageView.image = [self p_getUserThumbnail:user];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Tap to begin chat";
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = self.users[indexPath.row];
    NSDictionary *request = self.requests[user.objectId];
    NSString *groupId = request[@"groupId"];
    
    LMPrivateChatViewController *chatVC = [[LMPrivateChatViewController alloc] initWithFirebaseAddress:kFirebaseChatsAddress andGroupId:groupId fromRequest:request];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - Private Methods

-(void) p_setupFirebase
{
    self.firebase = [[Firebase alloc] initWithUrl:_firebasePath];
    
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if (!_userThumbnails) {
            self.userThumbnails = [[NSMutableDictionary alloc] init];
        }
        
        if (!_requests) {
            self.requests = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        
        for (FDataSnapshot *child in snapshot.children) {
            
            NSDictionary *request = child.value;
            if ([request[@"responded"] boolValue] == NO) {
                [userIds addObject:child.key];
                [self.requests setObject:child.value forKey:child.key];
            } else {
                [self.userThumbnails removeObjectForKey:child.key];
                [self.requests removeObjectForKey:child.key];
            }
        }
        if (userIds.count != 0) {
            [self p_getUsersProfiles:userIds];
        }
    }];
}

-(void) p_getUsersProfiles:(NSArray *)userIds
{
    [ParseConnection searchForUserIds:userIds withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (error != nil) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString lm_parseError:error];
        } else {
            self.users = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

-(UIImage *) p_getUserThumbnail:(PFUser *)user
{
    UIImage *image = nil;
    
    image = [self.userThumbnails objectForKey:user.objectId];
    
    if (image == nil) {
        
        ESTABLISH_WEAK_SELF;
        PFFile *imageFile = user[PF_USER_THUMBNAIL];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            ESTABLISH_STRONG_SELF;
            
            UIImage *image = [UIImage imageWithData:data];
            [strongSelf.userThumbnails setObject:image forKey:user.objectId];
            [strongSelf.tableView reloadData];
    
        }];
    }
    return image;
}

#pragma mark - Getter Methods
-(NSDictionary *)allRequests
{
    return [self.requests copy];
}

@end
