#import "LMLoginView.h"
#import "Parse/Parse.h"
#import "JGProgressHUD/JGProgressHUD.h"

@interface LMLoginView()

@property (strong, nonatomic) UITextField *username;
@property (strong, nonatomic) UITextField *password;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *signUpButton;

@end

@implementation LMLoginView

-(instancetype) init
{
    if (self = [super init]) {
        self.username = [UITextField new];
        self.username.borderStyle = UITextBorderStyleRoundedRect;
        self.username.placeholder = @"Username";
        
        self.password = [UITextField new];
        self.password.borderStyle = UITextBorderStyleRoundedRect;
        self.password.secureTextEntry = YES;
        self.password.placeholder = @"Password";
        
        self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.loginButton sizeToFit];
        [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.signUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
        [self.signUpButton sizeToFit];
        [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor blackColor];
        
        for (UIView *view in @[self.username, self.password, self.loginButton, self.signUpButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_username, _password, _loginButton, _signUpButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_username]-8-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_password]-8-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.signUpButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_username]-15-[_password]-15-[_loginButton]-15-[_signUpButton]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
}

#pragma mark - Target Action Methods
-(void) loginButtonPressed:(UIButton *)button
{
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    
    if ([username length] == 0 || [password length] == 0) {
        JGProgressHUD *alert = [JGProgressHUD new];
        alert.textLabel.text = @"Username and Password Combination is incorrect";
        [alert showInView:self];
        [alert dismissAfterDelay:3.0];
    } else {
        PFUser *user = [PFUser new];
        user.username = username;
        user.password = password;
        
        [self.delegate PFUser:user pressedLoginButton:button];
    }
}

-(void) signUpButtonPressed:(UIButton *)button
{
    [self.delegate userPressedSignUpButton:button];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
