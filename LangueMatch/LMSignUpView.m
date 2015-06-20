#import "LMSignUpView.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "LMAlertControllers.h"
#import "UIButton+TapAnimation.h"
#import "CALayer+BackgroundLayers.h"

#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <Parse/Parse.h>
#import <Twitter/Twitter.h>

@interface LMSignUpView()

@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) UIButton *twitterButton;

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@property (strong, nonatomic) UILabel *orLabel;

@end

@implementation LMSignUpView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _imageLayer = [CALayer layer];
        _imageLayer.contents = (id)[UIImage imageNamed:@"sunrise"].CGImage;
        _imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        [self.layer insertSublayer:_imageLayer atIndex:1];
        
        _gradientLayer = [CALayer lm_universalBackgroundColor];
        
        [[self layer] insertSublayer:_gradientLayer above:_imageLayer];
        [[self layer] setShadowColor:[UIColor whiteColor].CGColor];
        
        _signUpLabel = [[UILabel alloc] init];
        [_signUpLabel setText:@"LangMatch"];
        [_signUpLabel setFont:[UIFont lm_noteWorthyLarge]];
        [_signUpLabel setTextColor:[UIColor whiteColor]];
        
        _langMatchSlogan = [UILabel new];
        _langMatchSlogan.font = [UIFont lm_noteWorthySmall];
        _langMatchSlogan.text = @"- A Language Tutor For Everyone -";
        _langMatchSlogan.textColor = [UIColor whiteColor];
        _langMatchSlogan.textAlignment = NSTextAlignmentCenter;
        
        _usernameField = [[UITextField alloc] init];
        _usernameField.placeholder = @"username";
        
        _passwordField = [[UITextField alloc] init];
        _passwordField.secureTextEntry = YES;
        _passwordField.placeholder = @"password";
        
        _emailField = [[UITextField alloc] init];
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.placeholder = @"email";
        
        for (UITextField *textField in @[_usernameField, _passwordField, _emailField]) {
            textField.borderStyle = UITextBorderStyleNone;
            [textField setBackgroundColor:[[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f]];
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor whiteColor];
            textField.clearsOnBeginEditing = NO;
            textField.font = [UIFont lm_noteWorthyMedium];
            textField.keyboardAppearance = UIKeyboardTypeEmailAddress;
            
            [textField.layer setBorderColor:[UIColor whiteColor].CGColor];
            [textField.layer setCornerRadius:5.0f];
            [textField.layer setMasksToBounds:YES];
            
            UIView *leftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
            leftView.backgroundColor = [UIColor clearColor];
            [textField setLeftViewMode:UITextFieldViewModeAlways];
            [textField setLeftView: leftView];
        }
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont lm_noteWorthyMedium];
        [_signUpButton setTitleColor:[UIColor lm_wetAsphaltColor] forState:UIControlStateNormal];
        [[_signUpButton layer] setCornerRadius:5];
        _signUpButton.backgroundColor = [UIColor lm_cloudsColor];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _orLabel = [[UILabel alloc] init];
        [_orLabel setText:@"- Or -"];
        [_orLabel setFont:[UIFont lm_noteWorthyMedium]];
        [_orLabel setTextColor:[UIColor whiteColor]];
        
        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twitterButton setTitle:@"Log in with Twitter" forState:UIControlStateNormal];
        _twitterButton.backgroundColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1.0];
        [[_twitterButton layer] setCornerRadius:5.0f];
        [_twitterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [_twitterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_twitterButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_twitterButton addTarget:self action:@selector(twitterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *twitterLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TwitterLogo"]];
        twitterLogo.frame = CGRectMake(5 , 7.5, 35, 35);
        twitterLogo.contentMode = UIViewContentModeScaleAspectFit;
        [_twitterButton addSubview:twitterLogo];
        
        _facebookLoginButton = [[FBSDKLoginButton alloc] init];
        [_facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _haveAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_haveAccountButton setTitle:NSLocalizedString(@"Already have an account? Login", @"Already have an account? Login") forState:UIControlStateNormal];
        [_haveAccountButton setBackgroundColor:[UIColor clearColor]];
        [_haveAccountButton.titleLabel setFont:[UIFont lm_noteWorthySmall]];
        [_haveAccountButton addTarget:self action:@selector(haveAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.signUpLabel, self.langMatchSlogan, self.usernameField, self.passwordField, self.emailField, self.signUpButton, self.orLabel, self.twitterButton, self.facebookLoginButton, self.haveAccountButton])
        {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_signUpLabel, _langMatchSlogan, _usernameField, _passwordField, _emailField, _signUpButton, _orLabel, _twitterButton, _facebookLoginButton, _haveAccountButton);
    
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
        textFieldWidth = 375;
    }
    
    CENTER_VIEW_H(self, _signUpLabel);
    
    CONSTRAIN_WIDTH(_langMatchSlogan, buttonWidth);
    CENTER_VIEW_H(self, _langMatchSlogan);
    
    CONSTRAIN_WIDTH(_usernameField, textFieldWidth);
    CENTER_VIEW_H(self, _usernameField);
    
    CONSTRAIN_WIDTH(_passwordField, textFieldWidth);
    CENTER_VIEW_H(self, _passwordField);
    
    CONSTRAIN_WIDTH(_emailField, textFieldWidth);
    CENTER_VIEW_H(self, _emailField);
    
    CONSTRAIN_WIDTH(_signUpButton, buttonWidth);
    CENTER_VIEW_H(self, _signUpButton);
    
    CENTER_VIEW_H(self, _orLabel);
    
    CONSTRAIN_WIDTH(_twitterButton, buttonWidth);
    CENTER_VIEW_H(self, _twitterButton);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);
    
    CONSTRAIN_WIDTH(_haveAccountButton, buttonWidth);
    CENTER_VIEW_H(self, _haveAccountButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_signUpLabel]-8-[_langMatchSlogan]-15-[_usernameField(==45)]-2-[_passwordField(==45)]-2-[_emailField(==45)]-15-[_signUpButton(==55)]-8-[_haveAccountButton(==30)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_orLabel]-10-[_twitterButton(==50)]-8-[_facebookLoginButton(==50)]-15-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    _gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    [_twitterButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, textFieldWidth - 50)];
}

#pragma mark - Touch Handling

-(void)signUpButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    NSString *displayName = _usernameField.text;
    NSString *username = [_usernameField.text lowercaseString];
    NSString *email = [_emailField.text lowercaseString];
    NSString *password = _passwordField.text;
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"There was an Error Signing Up") message:NSLocalizedString(@"Check credentials", @"Please Check Credentials and try again") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (password.length <= 5)
    {
        message.message = @"Please choose a password longer than 5 characters";
        [message show];
    }
    else if ([email length] == 0)
    {
        message.message = @"Please enter your email - this only be used for password resets";
        [message show];
    }
    
    else
    {
        NSDictionary *userCredentials = @{PF_USER_USERNAME : username, PF_USER_DISPLAYNAME : displayName, PF_USER_EMAIL : email, PF_USER_PASSWORD : password};
        [self.delegate userWithCredentials:userCredentials pressedSignUpButton:sender];
    }
}

-(void) facebookButtonPressed:(UIButton *)sender
{
    [self.delegate facebookButtonPressed:sender];
}

-(void) twitterButtonPressed:(UIButton *)sender
{
    [self.delegate twitterButtonPressed:sender];
}

-(void) haveAccountButtonTapped:(UIButton *)button
{
    [self.delegate hasAccountButtonPressed];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_emailField resignFirstResponder];
}

@end
