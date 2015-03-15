#import "LMLoginViewController.h"
#import "QuickBlox/Quickblox.h"
#import "LMSignUpViewController.h"
#import "LMHomeScreenViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "LMLoginView.h"

@interface LMLoginViewController () <LMLoginViewDelegate>

@property (strong, nonatomic) LMLoginView *loginView;

@end

@implementation LMLoginViewController

-(instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView = [LMLoginView new];
    self.loginView.delegate = self;
    [self.view addSubview:self.loginView];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.loginView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height);
}


#pragma mark - LMLoginView Delegate
-(void)userPressedLoginButton:(UIButton *)button withQBSessionParameters:(QBSessionParameters *)parameters
{
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        NSLog(@"Login Successfull");
        [self presentHomeScreenViewController];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Error Logging In");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Check credentials" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)userPressedSignUpButton:(UIButton *)button
{
    [self presentSignUpViewController];
}

-(void) presentHomeScreenViewController
{
    UINavigationController *nav = [[UINavigationController alloc] init];
    
    LMHomeScreenViewController *homeScreenVC = [[LMHomeScreenViewController alloc] init];
    homeScreenVC.title = @"Home";
    [nav setViewControllers:@[homeScreenVC]];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) presentSignUpViewController
{
    LMSignUpViewController *signUpVC = [[LMSignUpViewController alloc] init];
    [self presentViewController:signUpVC animated:YES completion:nil];
}


#pragma mark -Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
