#import "LMHomeScreenViewController.h"
#import "LMHomeScreenView.h"
#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "Parse/Parse.h"
#import "LMChat.h"
#import "ChatView.h"

#import "LMNavigationControllerAnimator.h"

//Temporary Data Sync with SDK
#import "LMData.h"

//Temporary Core Data
#import "LMHTTPRequestManager.h"
#import "LMSyncEngine.h"
#import "LMUsers.h"
#import "SDCoreDataController.h"

typedef NS_ENUM (int, LMHomeButton) {
    LMHomeButtonChat        =    0,
    LMHomeButtonFriends     =    1,
    LMHomeButtonProfile     =    2,
    LMHomeButtonSomething   =    3
};



@interface LMHomeScreenViewController () <UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) LMHomeScreenView *homeScreen;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) LMFriendsListViewController *friendsListVC;
@property (strong, nonatomic) LMChatsListViewController *chatsListVC;
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) LMNavigationControllerAnimator *customNavigationAnimationController;

@end

@implementation LMHomeScreenViewController

NSString *const LMUserDidLogoutNotification = @"LMUserDidLogoutNotification";

-(instancetype)init
{
    if (self = [super init]) {
        
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_LM_HomeScreen.jpg"]];
//        self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
        self.backgroundImage.alpha = 1.0;
        
        [self.view addSubview:self.backgroundImage];
        [self.view sendSubviewToBack:self.backgroundImage];
    }
    return self;
}

#pragma mark - View Controller Life Cycle

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.homeScreen.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) + 10, self.view.bounds.size.width, self.view.bounds.size.height);
    self.backgroundImage.frame = CGRectMake(-50, 0, CGRectGetWidth(self.view.frame) + 100, CGRectGetHeight(self.view.frame));
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForBeginChatNotification];

    [LMData sharedInstance];
    
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
    
    
    /* --- TEmporary --- */
    self.chatsListVC.transitioningDelegate = self;
    self.chatsListVC.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:self.chatsListVC animated:YES completion:nil];
    /* --- TEmporary --- */
    
    
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


#pragma mark - View controller transitioning delegate

/* Needs Work */

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    LMNavigationControllerAnimator *animator = [LMNavigationControllerAnimator new];
    animator.reverse = NO;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    LMNavigationControllerAnimator *animator = [LMNavigationControllerAnimator new];
    animator.reverse = YES;
    return animator;
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
