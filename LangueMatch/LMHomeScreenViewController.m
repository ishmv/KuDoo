#import "LMHomeScreenViewController.h"
#import "LMHomeScreenView.h"
#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "Parse/Parse.h"
#import "LMChat.h"
#import "ChatView.h"

//Temporary Data Sync with SDK
#import "LMData.h"

//Temporary Core Data
#import "LMHTTPRequestManager.h"
#import "LMUser.h"
#import "LMSyncEngine.h"
#import "LMUsers.h"
#import "SDCoreDataController.h"

typedef NS_ENUM (int, LMHomeButton) {
    LMHomeButtonChat        =    0,
    LMHomeButtonFriends     =    1,
    LMHomeButtonProfile     =    2,
    LMHomeButtonSomething   =    3
};



@interface LMHomeScreenViewController () <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) LMHomeScreenView *homeScreen;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) LMFriendsListViewController *friendsListVC;
@property (strong, nonatomic) LMChatsListViewController *chatsListVC;

@end

@implementation LMHomeScreenViewController

NSString *const LMUserDidLogoutNotification = @"LMUserDidLogoutNotification";

-(instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - View Controller Life Cycle

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.homeScreen.frame = CGRectMake(0, 15, self.view.bounds.size.width, self.view.bounds.size.height);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForBeginChatNotification];

    [LMData sharedInstance];
//    [[LMHTTPRequestManager sharedClient] GET:@"users" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Trouble fetching data");
//    }];
    
//    [[LMSyncEngine sharedEngine] registerNSManagedObjectClassToSync:[LMUser class]];
//    [[LMSyncEngine sharedEngine] startSync];
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped)];
    [self.navigationItem setLeftBarButtonItem:logout];
    
    UIBarButtonItem *information = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(informationButtonTapped)];
    [self.navigationItem setRightBarButtonItem:information];
    
    self.homeScreen = [LMHomeScreenView new];
    self.homeScreen.collectionView.delegate = self;
    
    [self.view addSubview:self.homeScreen];
}

#pragma mark - Target Action

-(void) logoutButtonTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LMUserDidLogoutNotification object:nil];
}

-(void) informationButtonTapped
{
    //ToDo
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.4 options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         cell.contentView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished){
                         
                         if (indexPath.section == 0 && indexPath.item == 0) {
                             [self presentChat];
                         } else if (indexPath.section == 0 && indexPath.item == 1) {
                             [self presentFriendsList];
                         } else if (indexPath.section == 1 && indexPath.item == 0) {
                             [self presentUserProfile];
                         } else {
                             NSLog(@"Not Implemented Yet");
                         }
                     }];
}

-(void) presentChat
{
    if (!self.chatsListVC) {
        self.chatsListVC = [[LMChatsListViewController alloc] init];
        self.chatsListVC.title = @"Conversations";
    }
    
    [self.navigationController pushViewController:self.chatsListVC animated:YES];
}

-(void) presentUserProfile
{
    LMUserProfileViewController *userProfileVC = [[LMUserProfileViewController alloc] init];
    PFUser *user = [PFUser currentUser];
    userProfileVC.user = user;
    userProfileVC.title = user[PF_USER_USERNAME];
    
    [self.navigationController pushViewController:userProfileVC animated:YES];
}
     
-(void) presentFriendsList
{
    if (!self.friendsListVC) {
        self.friendsListVC = [[LMFriendsListViewController alloc] init];
        self.friendsListVC.title = @"Friends";
    }
    
    [self.navigationController pushViewController:self.friendsListVC animated:YES];
}


#pragma mark - Notifications

-(void)registerForBeginChatNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LMInitiateChatNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (!self.chatsListVC) {
            self.chatsListVC = [[LMChatsListViewController alloc] init];
            self.chatsListVC.title = @"Conversations";
        } else {
            [[LMChat sharedInstance] startChatWithUsers:@[note.object] completion:^(PFObject *chat, NSError *error) {
                
                ChatView *newChat = [[ChatView alloc] initWithChat:chat];
                [self.navigationController setViewControllers:@[self, self.chatsListVC, newChat]];
                [[LMData sharedInstance] checkServerForNewChats];
            }];
        }
    }];
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
