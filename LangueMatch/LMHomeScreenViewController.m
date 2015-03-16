#import "LMHomeScreenViewController.h"
#import "LMHomeScreenViewControllerCell.h"
#import "LMHomeScreenView.h"
#import "LMFriendsListViewController.h"
#import "LMChatsListViewController.h"
#import "LMChat.h"

@interface LMHomeScreenViewController () <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) LMHomeScreenView *homeScreen;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) LMFriendsListViewController *friendsListVC;
@property (strong, nonatomic) LMChatsListViewController *chatsListVC;

@end

@implementation LMHomeScreenViewController

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
    
    self.homeScreen = [LMHomeScreenView new];
    self.homeScreen.collectionView.delegate = self;
    
    [self.view addSubview:self.homeScreen];
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
                     } completion:^(BOOL finished) {
                         if (indexPath.item == 0) {
                             [self presentChatViewController];
                         } else {
                             
                         }
                     }];
}

-(void) presentChatViewController
{
    self.tabBarController = [[UITabBarController alloc] init];
    
    self.friendsListVC = [[LMFriendsListViewController alloc] init];
    self.chatsListVC = [[LMChatsListViewController alloc] init];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:self.friendsListVC];
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:self.chatsListVC];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addChatButtonPressed:)];
//    [nav2.navigationItem setRightBarButtonItem:addButton];
    
    self.tabBarController.viewControllers = @[nav1, nav2];
//    [self.tabBarController.navigationItem setRightBarButtonItem:addButton];
    [self.tabBarController.tabBarController.tabBar setItems:@[[UIImage imageNamed:@"sample-316-truck.png"],[UIImage imageNamed:@"sample-321-like.png"]]];
    
    [self.navigationController pushViewController:self.tabBarController animated:YES];
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
