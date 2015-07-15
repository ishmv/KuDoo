#import "LMSignUpProfileView.h"
#import "AppConstant.h"
#import "Utility.h"
#import "UIButton+TapAnimation.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"

#import <Parse/Parse.h>

@interface LMSignUpProfileView ()

@property (strong, nonatomic) UIButton *endCustomize;

@end

@implementation LMSignUpProfileView

-(instancetype) initWithUser:(PFUser *)user {
    
    if (self = [super initWithUser:user]) {
        [self p_fetchUserInformation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.endCustomize = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(userPressedFinishedButton:) forControlEvents:UIControlEventTouchUpInside];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [button.layer setCornerRadius:30.0f];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont lm_robotoRegularTitle]];
        [button.layer setBackgroundColor:[UIColor lm_tealColor].CGColor];
        [button setClipsToBounds:YES];
        button;
    });
    
    [self.view addSubview:self.endCustomize];
    
    [self.endCustomize addTarget:self action:@selector(userPressedFinishedButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.endCustomize];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CONSTRAIN_HEIGHT(_endCustomize, 60);
    CONSTRAIN_WIDTH(_endCustomize, 60);
    CENTER_VIEW_H(self.view, _endCustomize);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.view, _endCustomize, -8);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Handling

-(void) userPressedFinishedButton:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil];
}

#pragma mark - Network Fetch

-(void) p_fetchUserInformation
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.userInformation reloadData];
    }];
}

@end

