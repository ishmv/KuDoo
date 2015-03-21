#import "LMHomeScreenViewController.h"
#import "LMHomeScreenView.h"
#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "Parse/Parse.h"
#import "LMChat.h"
#import "ChatView.h"

typedef NS_ENUM(NSInteger, LMHomeButton) {
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


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.homeScreen.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForBeginChatNotification];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(logoutButtonTapped)];
    [self.navigationItem setRightBarButtonItem:logoutButton];
    
    self.homeScreen = [LMHomeScreenView new];
    self.homeScreen.collectionView.delegate = self;
    
    [self.view addSubview:self.homeScreen];
}

-(void) logoutButtonTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LMUserDidLogoutNotification object:nil];
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
                         
                         switch(indexPath.item)
                         {
                             case LMHomeButtonChat:
                                 [self presentChat];
                                 break;
                             case (LMHomeButtonProfile):
                                 [self presentUserProfile];
                                 break;
                             case (LMHomeButtonFriends):
                                 [self presentFriendsList];
                                 break;
                             default :
                                 NSLog(@"Not Implemented Yet");
                                 break;
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
            [[LMChat sharedInstance] startChatWithUsers:@[note.object] completion:^(NSString *groupId, NSError *error) {
                
                ChatView *newChat = [[ChatView alloc] initWithGroupId:groupId];
                [self.navigationController setViewControllers:@[self, self.chatsListVC, newChat]];
                
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
