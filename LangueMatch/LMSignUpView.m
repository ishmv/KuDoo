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

@interface LMSignUpView() <UITextFieldDelegate>

@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) UIButton *twitterButton;

@property (strong, nonatomic) CALayer *imageLayer;

@property (strong, nonatomic) UILabel *orLabel;

@end

@implementation LMSignUpView

static NSInteger const MAX_CHAT_TITLE_LENGTH = 20;

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
        
        _signUpLabel = [[UILabel alloc] init];
        [_signUpLabel setText:@"KuDoo"];
        [_signUpLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:40.0f]];
        [_signUpLabel setTextColor:[UIColor whiteColor]];
        
        _langMatchSlogan = [UILabel new];
        _langMatchSlogan.font = [UIFont lm_robotoLightMessage];
        _langMatchSlogan.text = NSLocalizedString(@"A Language Tutor For Everyone", @"a language tutor for everyone");
        _langMatchSlogan.textColor = [UIColor whiteColor];
        _langMatchSlogan.textAlignment = NSTextAlignmentCenter;
        
        _usernameField = [[UITextField alloc] init];
        _usernameField.placeholder = NSLocalizedString(@"Username", @"username");
        _usernameField.delegate = self;
        
        _passwordField = [[UITextField alloc] init];
        _passwordField.secureTextEntry = YES;
        _passwordField.placeholder = NSLocalizedString(@"Password", @"password");
        
        _emailField = [[UITextField alloc] init];
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.placeholder = NSLocalizedString(@"Email", @"email");
        
        for (UITextField *textField in @[_usernameField, _passwordField, _emailField]) {
            textField.borderStyle = UITextBorderStyleNone;
            [textField setBackgroundColor:[[UIColor lm_beigeColor] colorWithAlphaComponent:0.2f]];
            textField.textAlignment = NSTextAlignmentLeft;
            textField.textColor = [UIColor whiteColor];
            textField.clearsOnBeginEditing = NO;
            textField.font = [UIFont lm_robotoLightMessage];
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
        [_signUpButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        _signUpButton.tintColor = [UIColor whiteColor];
        [_signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[_signUpButton layer] setCornerRadius:30.0f];
        _signUpButton.backgroundColor = [UIColor lm_tealColor];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
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
        [_haveAccountButton setTitle:NSLocalizedString(@"Login Screen", @"login screen") forState:UIControlStateNormal];
        [_haveAccountButton setBackgroundColor:[UIColor clearColor]];
        [_haveAccountButton.titleLabel setFont:[UIFont lm_robotoLightMessage]];
        [_haveAccountButton addTarget:self action:@selector(haveAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.signUpLabel, self.langMatchSlogan, self.usernameField, self.passwordField, self.emailField, self.signUpButton,self.twitterButton, self.facebookLoginButton, self.haveAccountButton])
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
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_signUpLabel, _langMatchSlogan, _usernameField, _passwordField, _emailField, _signUpButton, _twitterButton, _facebookLoginButton, _haveAccountButton);
    
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
    
    CONSTRAIN_WIDTH(_signUpButton, 60);
    CENTER_VIEW_H(self, _signUpButton);
    
    CONSTRAIN_WIDTH(_twitterButton, buttonWidth);
    CENTER_VIEW_H(self, _twitterButton);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);
    
    CONSTRAIN_WIDTH(_haveAccountButton, buttonWidth);
    CENTER_VIEW_H(self, _haveAccountButton);
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_signUpLabel]-8-[_langMatchSlogan]-15-[_usernameField(==45)]-2-[_passwordField(==45)]-2-[_emailField(==45)]-15-[_signUpButton(==60)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_twitterButton(==50)]-8-[_facebookLoginButton(==50)]-15-[_haveAccountButton]-15-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
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
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (password.length <= 5)
    {
        message.message = NSLocalizedString(@"Password must be longer than 5 characters", @"password length message");
        [message show];
    }
    else if ([email length] == 0)
    {
        message.message = NSLocalizedString(@"No Email", @"no email");
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

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= MAX_CHAT_TITLE_LENGTH || returnKey;
}


@end
