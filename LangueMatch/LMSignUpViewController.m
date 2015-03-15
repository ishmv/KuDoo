#import "LMSignUpViewController.h"
#import "QuickBlox/Quickblox.h"
#import "LMSignUpView.h"

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
    
    self.signUpView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.activityIndicator.frame = CGRectMake(self.view.bounds.size.width/2 - 25, self.view.bounds.size.height/2 - 25, 50, 50);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signUpView = [LMSignUpView new];
    self.signUpView.delegate = self;
    
    for (UIView *view in @[self.signUpView, self.activityIndicator]) {
        [self.view addSubview:view];
    }
}


#pragma mark - Target Action Methods
-(void)userPressedSignUpButton:(UIButton *)button withUserCredentials:(QBUUser *)user
{
    [self.activityIndicator startAnimating];
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        
        UIAlertView *signUpAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", @"success")
                                                              message:NSLocalizedString(@"Welcome To LangueMatch.\nPlease Sign In", @"Welcome")
                                                             delegate:self cancelButtonTitle:nil otherButtonTitles:@"Cool", nil];
        
        [signUpAlert show];
        
    } errorBlock:^(QBResponse *response) {
        UIAlertView *signUpAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", @"error")
                                                              message:NSLocalizedString(@"There was an error signing in", nil)
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        
        [signUpAlert show];
        
    }];
    
    [self.activityIndicator stopAnimating];
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
