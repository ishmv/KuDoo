#import "LMSignUpViewController.h"
#import "LMSignUpView.h"
#import "Parse/Parse.h"
#import "LMUsers.h"

@interface LMSignUpViewController () <LMSignUpViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) LMSignUpView *signUpView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation LMSignUpViewController

-(instancetype)init
{
    if (self = [super init]) {
         self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

#pragma mark - View Controller Lifecycle

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.activityIndicator.frame = CGRectMake(self.view.bounds.size.width/2 - 25, self.view.bounds.size.height/2 - 25, 50, 50);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signUpView = [[LMSignUpView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height)];
    self.signUpView.delegate = self;
    
    for (UIView *view in @[self.signUpView, self.activityIndicator]) {
        [self.view addSubview:view];
    }
}


#pragma mark - Target Action Methods
-(void)PFUser:(PFUser *)user pressedSignUpButton:(UIButton *)button
{
    
    NSError *err;
    [user signUp:&err];
    
    if (!err) {
        [[LMUsers sharedInstance] saveUserProfileImage:[UIImage imageNamed:@"emptyprofilepicture.jpg"]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Application Life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
