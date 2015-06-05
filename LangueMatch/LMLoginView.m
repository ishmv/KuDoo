#import "LMLoginView.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"

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

@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@end

@implementation LMLoginView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _imageLayer = [CALayer layer];
        _imageLayer.contents = (id)[UIImage imageNamed:@"2.jpg"].CGImage;
        _imageLayer.contentsGravity = kCAGravityResizeAspect;
        _imageLayer.opacity = 0.4f;
        [self.layer insertSublayer:_imageLayer atIndex:1];
        
        _gradientLayer = ({
            CAGradientLayer *layer = [[CAGradientLayer alloc] init];
            layer.colors = @[(id)[UIColor lm_peterRiverColor].CGColor, (id)[[UIColor lm_orangeColor] colorWithAlphaComponent:0.8f].CGColor, (id)[[UIColor lm_wetAsphaltColor] colorWithAlphaComponent:1.0f] .CGColor];
            layer.opacity = 1.0f;
            layer;
        });
        
        [[self layer] insertSublayer:_gradientLayer above:_imageLayer];
        [[self layer] setShadowColor:[UIColor whiteColor].CGColor];
        
        _langueMatchLabel = [UILabel new];
        _langueMatchLabel.font = [UIFont lm_noteWorthyLarge];
        _langueMatchLabel.text = @"LangMatch";
        _langueMatchLabel.textColor = [UIColor whiteColor];
        _langueMatchLabel.textAlignment = NSTextAlignmentCenter;
        
        _langueMatchSlogan = [UILabel new];
        _langueMatchSlogan.font = [UIFont lm_noteWorthySmall];
        _langueMatchSlogan.text = @"- A Language Tutor For Everyone -";
        _langueMatchSlogan.textColor = [UIColor whiteColor];
        _langueMatchSlogan.textAlignment = NSTextAlignmentCenter;
        
        _username = [UITextField new];
        _username.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _username.autocorrectionType = UITextAutocorrectionTypeNo;
        _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _username.borderStyle = UITextBorderStyleRoundedRect;
        _username.placeholder = @"username";
        _username.clearsOnBeginEditing = YES;
        [_username setFont:[UIFont lm_noteWorthyMedium]];
        _username.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
        _username.textAlignment = NSTextAlignmentLeft;
        
        _password = [UITextField new];
        _password.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _password.autocorrectionType = UITextAutocorrectionTypeNo;
        _password.borderStyle = UITextBorderStyleRoundedRect;
        _password.secureTextEntry = YES;
        _password.textAlignment = NSTextAlignmentLeft;
        _password.clearsOnBeginEditing = YES;
        [_password setFont:[UIFont lm_noteWorthyMedium]];
        _password.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
        _password.placeholder = @"password";
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont lm_noteWorthyMedium];
        [_loginButton setTitleColor:[UIColor lm_wetAsphaltColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor whiteColor];
        [_loginButton.layer setCornerRadius:5.0f];
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        _facebookLoginButton = [[FBSDKLoginButton alloc] init];
//        [_facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [_signUpButton.titleLabel setFont:[UIFont lm_noteWorthySmall]];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPasswordButton setTitle:@"Forgot Password" forState:UIControlStateNormal];
        [_forgotPasswordButton.titleLabel setFont:[UIFont lm_noteWorthySmall]];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonSeparator = [[UILabel alloc] init];
        [_buttonSeparator setText:@"|"];
        [_buttonSeparator setTextColor:[UIColor whiteColor]];
        
        for (UIView *view in @[self.langueMatchSlogan, self.langueMatchLabel, self.username, self.password, self.loginButton, self.facebookLoginButton, self.signUpButton, self.buttonSeparator, self.forgotPasswordButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_langueMatchSlogan, _langueMatchLabel, _username, _password, _loginButton, _facebookLoginButton, _signUpButton, _buttonSeparator, _forgotPasswordButton);
    
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
    
    CONSTRAIN_WIDTH(_loginButton, buttonWidth);
    CENTER_VIEW_H(self, _loginButton);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);
    
    CONSTRAIN_WIDTH(_signUpButton, viewWidth/2 - 15);
    ALIGN_VIEW_RIGHT_CONSTANT(self, _signUpButton, -15);
    
    CONSTRAIN_WIDTH(_forgotPasswordButton, viewWidth/2 - 15);
    ALIGN_VIEW_LEFT_CONSTANT(self, _forgotPasswordButton, 15);
    ALIGN_VIEW_BOTTOM(self, _forgotPasswordButton);
    CONSTRAIN_HEIGHT(_forgotPasswordButton, 50);
    
    CENTER_VIEW_H(self, _buttonSeparator);
    ALIGN_VIEW_BOTTOM_CONSTANT(self, _buttonSeparator, -15);
        
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_langueMatchLabel]-8-[_langueMatchSlogan]-25-[_username(==45)]-2-[_password(==45)]-15-[_loginButton(==50)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_facebookLoginButton(==50)]-8-[_signUpButton(==50)]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];

    self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.frame));
    _imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}


#pragma mark - Touch Handling

-(void) loginButtonPressed:(UIButton *)button
{
    [self animateButtonPush:button];
    
    NSString *username = [_username.text lowercaseString];
    NSString *password = [_password.text lowercaseString];
    
    if ([username length] == 0 || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete")
                                                        message:NSLocalizedString(@"Please Enter Password/Username", @"Please Enter Password/Username")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"SignUp for LangueMatch", nil];
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
