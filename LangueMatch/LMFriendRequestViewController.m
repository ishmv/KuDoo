#import "LMFriendRequestViewController.h"
#import "LMFriendRequestUserProfileViewController.h"
#import "LMParseConnection.h"
#import "LMListViewCell.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendRequestViewController () <LMFriendRequestUserProfileViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *waitingResponseRequests;
@property (strong, nonatomic) NSMutableArray *sentRequests;

@end

@implementation LMFriendRequestViewController

static NSString *reuseIdentifer = @"reuseIdentifier";
static CGFloat const cellHeight = 70;

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]){
        
        [self p_getFriendRequests];
        [self registerForFriendRequestNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LMListViewCell class] forCellReuseIdentifier:reuseIdentifer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:PF_FRIEND_REQUEST];
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
            return self.sentRequests.count;
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
        {
            request = self.waitingResponseRequests[indexPath.row];
            PFUser *user = request[PF_FRIEND_REQUEST_SENDER];
            [user fetchIfNeeded];
            cell.user = user;
            break;
        }
        case 1:
        {
            request = self.sentRequests[indexPath.row];
            PFUser *user = request[PF_FRIEND_REQUEST_RECEIVER];
            [user fetchIfNeeded];
            cell.user = user;
            break;
        }
        default:
            break;
    }
    
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
            return @"Waiting Your Response";
            break;
        case 1:
            return @"Pending Requests";
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
            request = self.sentRequests[indexPath.row];
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
    
    PFUser *user = request[PF_FRIEND_REQUEST_SENDER];
    [self.delegate addUserToFriendList:user];
    
    [self p_acceptRequest:request];
    [LMParseConnection acceptFriendRequest:request];
}

-(void) userDeclinedFriendRequest:(PFObject *)request
{
    [self.waitingResponseRequests removeObject:request];
    
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
        
        [self p_filterRequestsFromArray:@[request]];
    }];
}

#pragma mark - Private Methods

-(void) p_getFriendRequests
{
    [LMParseConnection getFriendRequestsForCurrentUserWithCompletion:^(NSArray *requests, NSError *error) {
        [self p_filterRequestsFromArray: requests];
    }];
}

-(void) p_filterRequestsFromArray:(NSArray *)requests
{
    PFUser *currentUser = [PFUser currentUser];
    
    for (PFObject *friendRequest in requests)
    {
        if (friendRequest[PF_FRIEND_REQUEST_RECEIVER] == currentUser)
        {
            if ([friendRequest[PF_FRIEND_REQUEST_WAITING_RESPONSE] boolValue])
            {
                if (!_waitingResponseRequests) _waitingResponseRequests = [NSMutableArray array];
                if (![_waitingResponseRequests containsObject:friendRequest]) [self.waitingResponseRequests addObject:friendRequest];
            }
        }
        else if (friendRequest[PF_FRIEND_REQUEST_SENDER] == currentUser)
        {
            if ([friendRequest[PF_FRIEND_REQUEST_WAITING_RESPONSE] boolValue])
            {
                if (!_sentRequests) _sentRequests = [NSMutableArray array];
                if (![_sentRequests containsObject:friendRequest])  [self.sentRequests addObject:friendRequest];
            }
            else if (friendRequest[PF_FRIEND_REQUEST_ACCEPTED])
            {
                PFUser *user = friendRequest[PF_FRIEND_REQUEST_RECEIVER];
                [self.sentRequests removeObject:friendRequest];
                [LMParseConnection addFriendshipRelationWithUser:user];
                [self.delegate addUserToFriendList:user];
                [self p_acceptRequest:friendRequest];
            }
        }
    }
    
    [self p_incrementTabBarBadgeValue];
    [self.tableView reloadData];
}

-(void) p_acceptRequest:(PFObject *)request
{
    [self.tableView reloadData];
    [self p_incrementTabBarBadgeValue];
    
    if (self.waitingResponseRequests.count == 0) [self.navigationController popToRootViewControllerAnimated:YES];
    else [self.navigationController popViewControllerAnimated:YES];
    
    [request unpinInBackground];
}

-(void) p_incrementTabBarBadgeValue
{
    [self.delegate newFriendRequestCount:@(self.waitingResponseRequests.count)];
}

@end
