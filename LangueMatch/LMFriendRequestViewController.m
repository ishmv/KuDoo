#import "LMFriendRequestViewController.h"
#import "LMFriendRequestUserProfileViewController.h"
#import "LMFriendRequestModel.h"
#import "LMParseConnection.h"
#import "LMListViewCell.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendRequestViewController () <LMFriendRequestUserProfileViewControllerDelegate>

@property (strong, nonatomic) LMFriendRequestModel *friendRequestModel;

@property (strong, nonatomic) NSMutableArray *waitingResponseRequests;
@property (strong, nonatomic) NSMutableArray *acceptedRequests;
@property (strong, nonatomic) NSMutableArray *declinedRequests;

@end

@implementation LMFriendRequestViewController

static NSString *reuseIdentifer = @"reuseIdentifier";
static CGFloat const cellHeight = 70;

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]){
        if (!_friendRequestModel) _friendRequestModel = [[LMFriendRequestModel alloc] init];
        [self.friendRequestModel addObserver:self forKeyPath:@"friendRequests" options:0 context:nil];
        [self registerForFriendRequestNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.friendRequestModel addObserver:self forKeyPath:@"friendRequests" options:0 context:nil];
    
    [self.tableView registerClass:[LMListViewCell class] forCellReuseIdentifier:reuseIdentifer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [self.friendRequestModel removeObserver:self forKeyPath:@"friendRequests"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.waitingResponseRequests.count;
            break;
        case 1:
            return self.acceptedRequests.count;
            break;
        case 2:
            return self.declinedRequests.count;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    }
    
    PFObject *request;
    
    switch (indexPath.section) {
        case 0:
            request = self.waitingResponseRequests[indexPath.row];
            break;
        case 1:
            request = self.acceptedRequests[indexPath.row];
            break;
        case 2:
            request = self.declinedRequests[indexPath.row];
            break;
        default:
            break;
    }
    
    cell.user = request[PF_FRIEND_REQUEST_SENDER];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return cellHeight;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Waiting Response";
            break;
        case 1:
            return @"Accepted";
            break;
        case 2:
            return @"Declined";
            break;
        default:
            return @"";
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *request;
    
    switch (indexPath.section) {
        case 0:
            request = self.waitingResponseRequests[indexPath.row];
            break;
        case 1:
            request = self.acceptedRequests[indexPath.row];
            break;
        case 2:
            request = self.declinedRequests[indexPath.row];
            break;
        default:
            break;
    }
    
    LMFriendRequestUserProfileViewController *userVC = [[LMFriendRequestUserProfileViewController alloc] initWithRequest:request];
    userVC.delegate = self;
    [self.navigationController pushViewController:userVC animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - MFriendRequestUserProfileViewController delegate

-(void) userAcceptedFriendRequest:(PFObject *)request
{
    [self.waitingResponseRequests removeObject:request];
    [self.acceptedRequests addObject:request];
    
    PFUser *user = request[PF_FRIEND_REQUEST_SENDER];
    [self.delegate addUserToFriendList:user];
    
    request[PF_FRIEND_REQUEST_WAITING_RESPONSE] = @(NO);
    request[PF_FRIEND_REQUEST_ACCEPTED] = @(YES);
    
    [LMParseConnection acceptFriendRequest:request];
    
    [self.tableView reloadData];
    [self p_incrementTabBarBadgeValue];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) userDeclinedFriendRequest:(PFObject *)request
{
    [self.waitingResponseRequests removeObject:request];
    [self.declinedRequests addObject:request];
    
    request[PF_FRIEND_REQUEST_WAITING_RESPONSE] = nil;
    request[PF_FRIEND_REQUEST_DECLINED] = @(YES);
    
    
    [self.tableView reloadData];
    [self p_incrementTabBarBadgeValue];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - NSNotifications

-(void) registerForFriendRequestNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_FRIEND_REQUEST object:nil queue:nil usingBlock:^(NSNotification *note) {
        PFObject *request = note.object;
        
        [self.friendRequestModel addFriendRequestsObject:request];
        [self p_filterRequests];
    }];
}


#pragma mark - Key Value Observing

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"friendRequests"] && [object isKindOfClass:[LMFriendRequestModel class]])
    {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting)
        {
            [self p_filterRequests];
        }
    }
}

#pragma mark - Private Methods

-(void) p_filterRequests
{
    for (PFObject *friendRequest in self.friendRequestModel.friendRequests)
    {
        if ([friendRequest[PF_FRIEND_REQUEST_WAITING_RESPONSE] boolValue])
        {
            if (!_waitingResponseRequests) _waitingResponseRequests = [NSMutableArray array];
            if (![_waitingResponseRequests containsObject:friendRequest]) [self.waitingResponseRequests addObject:friendRequest];
        }
        else if ([friendRequest[PF_FRIEND_REQUEST_ACCEPTED] boolValue])
        {
            if (!_acceptedRequests) _acceptedRequests = [NSMutableArray array];
            if (![_acceptedRequests containsObject:friendRequest])  [self.acceptedRequests addObject:friendRequest];
        }
        else if ([friendRequest[PF_FRIEND_REQUEST_DECLINED] boolValue])
        {
            if (!_declinedRequests) _declinedRequests = [NSMutableArray array];
            if(![_declinedRequests containsObject:friendRequest])   [self.declinedRequests addObject:friendRequest];
        }
    }
    
    [self p_incrementTabBarBadgeValue];
    [self.tableView reloadData];
}

-(void) p_incrementTabBarBadgeValue
{
    [self.delegate newFriendRequestCount:@(self.waitingResponseRequests.count)];
}

@end
