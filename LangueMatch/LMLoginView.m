#import "LMLoginView.h"
#import "Parse/Parse.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import "UIFont+ApplicationFonts.h"
#import <QuartzCore/QuartzCore.h>

@interface LMLoginView()

@property (strong, nonatomic) UIImageView *worldView;
@property (strong, nonatomic) UITextField *username;
@property (strong, nonatomic) UITextField *password;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *facebookLoginButton;
@property (strong, nonatomic) UIActivityIndicatorView *loginIndicator;

@end

@implementation LMLoginView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        
        self.worldView = [UIImageView new];
        self.worldView.image = [UIImage imageNamed:@"PeopleAroundTheWorld.jpg"];
        self.worldView.contentMode = UIViewContentModeScaleAspectFit;
        self.worldView.alpha = 1.0;
        
        self.username = [UITextField new];
        self.username.borderStyle = UITextBorderStyleRoundedRect;
        self.username.placeholder = @"Username";
        self.username.clearsOnBeginEditing = YES;
        [self.username setFont:[UIFont applicationFontLarge]];
        self.username.textAlignment = NSTextAlignmentCenter;
        
        self.password = [UITextField new];
        self.password.borderStyle = UITextBorderStyleRoundedRect;
        self.password.secureTextEntry = YES;
        self.password.textAlignment = NSTextAlignmentCenter;
        self.password.clearsOnBeginEditing = YES;
        [self.password setFont:[UIFont applicationFontLarge]];
        self.password.placeholder = @"Password";
        
        self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        self.loginButton.titleLabel.font = [UIFont applicationFontLarge];
        self.loginButton.backgroundColor = [UIColor clearColor];
        self.loginButton.titleLabel.textColor = [UIColor whiteColor];
        self.loginButton.layer.cornerRadius = 15;
        self.loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.loginButton.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0];
        [[self.loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[self.loginButton layer] setBorderWidth:1.0];
        self.loginButton.clipsToBounds = YES;
        [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
        self.signUpButton.titleLabel.font = [UIFont applicationFontLarge];
        self.signUpButton.titleLabel.textColor = [UIColor whiteColor];
        self.signUpButton.layer.cornerRadius = 15;
        self.signUpButton.clipsToBounds = YES;
        self.signUpButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:126/255.0 blue:34/255.0 alpha:1.0];
        [[self.signUpButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[self.signUpButton layer] setBorderWidth:1.0];
        [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.facebookLoginButton setTitle:@"Facebook Login" forState:UIControlStateNormal];
        self.facebookLoginButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        self.facebookLoginButton.titleLabel.textColor = [UIColor whiteColor];
        self.facebookLoginButton.layer.cornerRadius = 15;
        self.facebookLoginButton.clipsToBounds = YES;
        self.facebookLoginButton.backgroundColor = [UIColor colorWithRed:109/255.0 green:132/255.0 blue:180/255.0 alpha:1.0];
        [[self.facebookLoginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[self.facebookLoginButton layer] setBorderWidth:1.0];
        [self.facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.loginIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loginIndicator.frame = CGRectMake(0, 0, 150, 150);
        
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor blackColor];
        
        for (UIView *view in @[self.worldView, self.username, self.password, self.loginButton, self.signUpButton, self.loginIndicator, self.facebookLoginButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_worldView, _username, _password, _loginButton, _signUpButton, _loginIndicator, _facebookLoginButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_username]-50-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_password]-50-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_worldView]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_facebookLoginButton]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_loginButton]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_signUpButton]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_worldView]-15-[_username(==45)]-15-[_password(==45)]-15-[_facebookLoginButton]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_facebookLoginButton(==50)]-15-[_loginButton(==50)]-15-[_signUpButton(==50)]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loginIndicator
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loginIndicator
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0]];
}


#pragma mark - Target Action Methods
-(void) loginButtonPressed:(UIButton *)button
{
    [self showLoginIndicatorView];
    [self animateButtonPush:button];
    
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Password or UserName", @"No Username or Password")
                                                        message:NSLocalizedString(@"Please Enter Password/Username", @"Please Enter Password/Username")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"SignUp", nil];
        [alert show];
    } else {
        PFUser *user = [PFUser new];
        user.username = username;
        user.password = password;
        
        [self.delegate PFUser:user pressedLoginButton:button];
    }
}

-(void) signUpButtonPressed:(UIButton *)button
{
    [self animateButtonPush:button];
    
    [self.delegate userPressedSignUpButton:button];
}

-(void) animateButtonPush:(UIButton *)button
{
    button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.transform = CGAffineTransformIdentity;
    } completion:nil
     ];
}

-(void) facebookButtonPressed:(UIButton *)button
{
    [self.delegate userPressedLoginWithFacebookButton:button];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

-(void) showLoginIndicatorView
{
    self.loginIndicator.color = [UIColor blackColor];
    self.loginIndicator.backgroundColor = [UIColor blueColor];
//    [self.loginIndicator startAnimating];
}

@end
