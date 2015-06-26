#import "LMLoginView.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "CALayer+BackgroundLayers.h"

#import <Parse/Parse.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>

@interface LMLoginView()

@property (strong, nonatomic) UILabel *langueMatchLabel;
@property (strong, nonatomic) UILabel *langueMatchSlogan;
@property (strong, nonatomic) UITextField *username;
@property (strong, nonatomic) UITextField *password;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *forgotPasswordButton;
@property (strong, nonatomic) UILabel *buttonSeparator;

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@end

@implementation LMLoginView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffect.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        
        [visualEffect.contentView addSubview:vibrancyEffectView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageLayer = [CALayer layer];
        _imageLayer.contents = (id)[UIImage imageNamed:@"personTyping"].CGImage;
        _imageLayer.contentsGravity = kCAGravityResizeAspect;
        [self.layer insertSublayer:_imageLayer atIndex:0];
        
         [self addSubview:visualEffect];
        
        _langueMatchLabel = [UILabel new];
        _langueMatchLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:40.0f];
        _langueMatchLabel.text = @"KuDoo";
        _langueMatchLabel.textColor = [UIColor whiteColor];
        _langueMatchLabel.textAlignment = NSTextAlignmentCenter;
        
        _langueMatchSlogan = [UILabel new];
        _langueMatchSlogan.font = [UIFont lm_robotoLightMessage];
        _langueMatchSlogan.text = NSLocalizedString(@"A Language Tutor For Everyone", @"A Language Tutor For Everyone");
        _langueMatchSlogan.textColor = [UIColor whiteColor];
        _langueMatchSlogan.textAlignment = NSTextAlignmentCenter;
        
        _username = [UITextField new];
        _username.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _username.autocorrectionType = UITextAutocorrectionTypeNo;
        _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _username.borderStyle = UITextBorderStyleNone;
        _username.placeholder = NSLocalizedString(@"username", @"username");
        _username.clearsOnBeginEditing = YES;
        [_username setFont:[UIFont lm_robotoLightMessage]];
        _username.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
        _username.textColor = [UIColor whiteColor];
        _username.textAlignment = NSTextAlignmentLeft;
        [_username.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_username.layer setCornerRadius:5.0f];
        [_username.layer setMasksToBounds:YES];
        
        UIView *usernameLeftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
        usernameLeftView.backgroundColor = [UIColor clearColor];
        [_username setLeftViewMode:UITextFieldViewModeAlways];
        [_username setLeftView:usernameLeftView];
        
        _password = [UITextField new];
        _password.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _password.autocorrectionType = UITextAutocorrectionTypeNo;
        _password.borderStyle = UITextBorderStyleNone;
        _password.secureTextEntry = YES;
        _password.textAlignment = NSTextAlignmentLeft;
        _password.clearsOnBeginEditing = YES;
        [_password setFont:[UIFont lm_robotoLightMessage]];
        _password.textColor = [UIColor whiteColor];
        _password.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
        _password.placeholder = NSLocalizedString(@"password", @"password");
        [_password.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_password.layer setCornerRadius:5.0f];
        [_password.layer setMasksToBounds:YES];
        
        UIView *passwordLeftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
        passwordLeftView.backgroundColor = [UIColor clearColor];
        [_password setLeftViewMode:UITextFieldViewModeAlways];
        [_password setLeftView:passwordLeftView];
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor lm_tealColor];
        [_loginButton.layer setCornerRadius:30.0f];
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:NSLocalizedString(@"Sign Up", @"Sign Up") forState:UIControlStateNormal];
        [_signUpButton.titleLabel setFont:[UIFont lm_robotoLightMessage]];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPasswordButton setTitle:NSLocalizedString(@"Forgot Password", @"Forgot Password") forState:UIControlStateNormal];
        [_forgotPasswordButton.titleLabel setFont:[UIFont lm_robotoLightMessage]];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonSeparator = [[UILabel alloc] init];
        [_buttonSeparator setText:@"|"];
        [_buttonSeparator setTextColor:[UIColor whiteColor]];
        
        for (UIView *view in @[self.langueMatchSlogan, self.langueMatchLabel, self.username, self.password, self.loginButton, self.signUpButton, self.buttonSeparator, self.forgotPasswordButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_langueMatchSlogan, _langueMatchLabel, _username, _password, _loginButton, _signUpButton, _buttonSeparator, _forgotPasswordButton);
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat buttonWidth;
    CGFloat textFieldWidth;
    
    if (IS_IPHONE)
    {
        buttonWidth = 315;
        textFieldWidth = 300;
    }
    else if (IS_IPAD)
    {
        buttonWidth = 400;
        textFieldWidth = 350;
    }
    
    CONSTRAIN_WIDTH(_langueMatchLabel, viewWidth + 20);
    CENTER_VIEW_H(self, _langueMatchLabel);
    
    CONSTRAIN_WIDTH(_langueMatchSlogan, viewWidth);
    CENTER_VIEW_H(self, _langueMatchSlogan);
    
    CONSTRAIN_WIDTH(_username, textFieldWidth);
    CENTER_VIEW_H(self, _username);
    
    CONSTRAIN_WIDTH(_password, textFieldWidth);
    CENTER_VIEW_H(self, _password);
    
    CONSTRAIN_WIDTH(_loginButton, 60);
    CENTER_VIEW_H(self, _loginButton);
    
    CONSTRAIN_WIDTH(_signUpButton, viewWidth/2 - 15);
    ALIGN_VIEW_RIGHT_CONSTANT(self, _signUpButton, -15);
    
    CONSTRAIN_WIDTH(_forgotPasswordButton, viewWidth/2 - 15);
    ALIGN_VIEW_LEFT_CONSTANT(self, _forgotPasswordButton, 15);
    CONSTRAIN_HEIGHT(_forgotPasswordButton, 50);
    
    CENTER_VIEW_H(self, _buttonSeparator);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_langueMatchLabel]-8-[_langueMatchSlogan]-15-[_username(==45)]-2-[_password(==45)]-15-[_loginButton(==60)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    ALIGN_VIEWS_VERTICAL(self, _forgotPasswordButton, _signUpButton);
    ALIGN_VIEWS_VERTICAL(self, _buttonSeparator, _signUpButton);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self, _signUpButton, -15);
    
    self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.frame));
    _imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}


#pragma mark - Touch Handling

-(void) loginButtonPressed:(UIButton *)button
{
    [self animateButtonPush:button];
    
    NSString *username = [_username.text lowercaseString];
    NSString *password = _password.text;
    
    if ([username length] == 0 || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete")
                                                        message:NSLocalizedString(@"Missing credentials", @"Missing credentials")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Sign Up", @"Sign Up"), nil];
        [alert show];
    }
    else
    {
        [self.delegate LMUser:username pressedLoginButton:button withPassword:password];
    }
}

-(void) signUpButtonPressed:(UIButton *)sender
{
    [self animateButtonPush:sender];
    [self.delegate userPressedSignUpButton:sender];
}

-(void) animateButtonPush:(UIButton *)button
{
    button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{button.transform = CGAffineTransformIdentity;} completion:nil];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in @[self.username, self.password]) {
        [view resignFirstResponder];
        view.transform = CGAffineTransformIdentity;
    }
}

-(void) forgotPasswordButtonPressed:(UIButton *)sender
{
    [self.delegate userPressedForgotPasswordButton:sender];
}

@end