#import "LMSignUpView.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "LMAlertControllers.h"
#import "UIButton+TapAnimation.h"

#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <Parse/Parse.h>
#import <Twitter/Twitter.h>

#import <Crashlytics/Crashlytics.h>

@interface LMSignUpView() <UITextFieldDelegate, UIAlertViewDelegate>

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
        
        _imageLayer = ({
            CALayer *layer = [CALayer layer];
            layer.contents = (id)[UIImage imageNamed:@"personTyping"].CGImage;
            layer.contentsGravity = kCAGravityResizeAspect;
            layer;
        });

        [self.layer insertSublayer:_imageLayer atIndex:0];
        
        [self addSubview:visualEffect];
        
        _signUpLabel = ({
            UILabel *label = [UILabel new];
            [label setText:@"KuDoo"];
            [label setFont:[UIFont fontWithName:@"Roboto-Regular" size:40.0f]];
            [label setTextColor:[UIColor whiteColor]];
            label;
        });
        
        _langMatchSlogan = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont lm_robotoLightMessage];
            label.text = NSLocalizedString(@"Language Interaction For Millenials", @"language interaction for millenials");
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });

        _usernameField = ({
            UITextField *textField = [[UITextField alloc] init];
            textField.placeholder = NSLocalizedString(@"Username", @"username");
            textField.delegate = self;
            textField;
        });

        _passwordField = ({
            UITextField *textField = [[UITextField alloc] init];
            textField.secureTextEntry = YES;
            textField.placeholder = NSLocalizedString(@"Password", @"password");
            textField;
        });
        
        _emailField = ({
           UITextField *textField = [[UITextField alloc] init];
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.placeholder = NSLocalizedString(@"Email", @"email");
            textField;
        });

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
        
        _signUpButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
            button.tintColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[button layer] setCornerRadius:30.0f];
            button.backgroundColor = [UIColor lm_tealColor];
            [button addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        _twitterButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"Log in with Twitter" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1.0];
            [[button layer] setCornerRadius:5.0f];
            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [button addTarget:self action:@selector(twitterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });

        UIImageView *twitterLogo = ({
           UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TwitterLogo"]];
            imageView.frame = CGRectMake(5 , 7.5, 35, 35);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        });
        
        [_twitterButton addSubview:twitterLogo];
        
        _facebookLoginButton = ({
            FBSDKLoginButton *button = [[FBSDKLoginButton alloc] init];
            [button addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });

        _haveAccountButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:NSLocalizedString(@"Login Screen", @"login screen") forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor clearColor]];
            [button.titleLabel setFont:[UIFont lm_robotoLightMessage]];
            [button addTarget:self action:@selector(haveAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        for (UIView *view in @[self.signUpLabel, self.langMatchSlogan, self.usernameField, self.passwordField, self.emailField, self.signUpButton,self.twitterButton, self.facebookLoginButton, self.haveAccountButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

//#define CONSTRAIN_VISUALLY(VIEW, FORMAT) [(VIEW) addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:viewDictionary]]

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_signUpLabel, _langMatchSlogan, _usernameField, _passwordField, _emailField, _signUpButton, _twitterButton, _facebookLoginButton, _haveAccountButton);
    
    CGFloat buttonWidth;
    CGFloat textFieldWidth;
    
    if (IS_IPHONE) {
        buttonWidth = 315;
        textFieldWidth = 300;
    } else if (IS_IPAD) {
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
    
    CONSTRAIN_VISUALLY(self, @"V:|-30-[_signUpLabel]-8-[_langMatchSlogan]-15-[_usernameField(==45)]-2-[_passwordField(==45)]-2-[_emailField(==45)]-15-[_signUpButton(==60)]");
    CONSTRAIN_VISUALLY(self, @"V:[_twitterButton(==50)]-8-[_facebookLoginButton(==50)]-15-[_haveAccountButton]-15-|");
    
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
    
    if (username.length <= 5) {
        self.alertIsShowing = YES;
        message.message = NSLocalizedString(@"Username must be longer than 5 characters", @"username length message");
        [message show];
    } else if (password.length <= 5) {
        self.alertIsShowing = YES;
        message.message = NSLocalizedString(@"Password must be longer than 5 characters", @"password length message");
        [message show];
    } else if ([email length] == 0 || ![email containsString:@"@"] || ![email containsString:@"."]){
        self.alertIsShowing = YES;
        message.message = NSLocalizedString(@"Invalid Email", @"Invalid email");
        [message show];
    } else {
        NSDictionary *userCredentials = @{PF_USER_USERNAME : username, PF_USER_DISPLAYNAME : displayName, PF_USER_EMAIL : email, PF_USER_PASSWORD : password};
        [self.delegate userWithCredentials:userCredentials pressedSignUpButton:sender];
    }
}

-(void) facebookButtonPressed:(UIButton *)sender
{
    [[Crashlytics sharedInstance] crash];
    [self.delegate facebookButtonPressed:sender];
}

-(void) twitterButtonPressed:(UIButton *)sender
{
    [self.delegate twitterButtonPressed:sender];
}

-(void) haveAccountButtonTapped:(UIButton *)sender
{
    [self.delegate hasAccountButtonPressed:sender];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertIsShowing = NO;
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
