#import "LMLoginView.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "UIButton+TapAnimation.h"
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
        
        _langueMatchLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont fontWithName:@"Roboto-Regular" size:40.0f];
            label.text = @"KuDoo";
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        
        _langueMatchSlogan = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont lm_robotoLightMessage];
            label.text = NSLocalizedString(@"Language Interaction For Millenials", @"language interaction for millenials");
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        
        _username = ({
            UITextField *textField = [UITextField new];
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.placeholder = NSLocalizedString(@"Username", @"username");
            textField;
        });

        
        UIView *usernameLeftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
        usernameLeftView.backgroundColor = [UIColor clearColor];
        [_username setLeftViewMode:UITextFieldViewModeAlways];
        [_username setLeftView:usernameLeftView];
        
        _password = ({
            UITextField *textField = [UITextField new];
            textField.secureTextEntry = YES;
            textField.placeholder = NSLocalizedString(@"Password", @"password");
            textField;
        });
        
        UIView *passwordLeftView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
        passwordLeftView.backgroundColor = [UIColor clearColor];
        [_password setLeftViewMode:UITextFieldViewModeAlways];
        [_password setLeftView:passwordLeftView];
        
        for (UITextField *textField in @[_username, _password]) {
            textField.borderStyle = UITextBorderStyleNone;
            textField.keyboardAppearance = UIKeyboardTypeDefault;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            [textField setFont:[UIFont lm_robotoLightMessage]];
            textField.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
            textField.textColor = [UIColor whiteColor];
            textField.textAlignment = NSTextAlignmentLeft;
            textField.clearsOnBeginEditing = NO;
            [textField.layer setBorderColor:[UIColor whiteColor].CGColor];
            [textField.layer setCornerRadius:5.0f];
            [textField.layer setMasksToBounds:YES];
        }

        _loginButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor lm_tealColor];
            [button.layer setCornerRadius:30.0f];
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        _signUpButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:NSLocalizedString(@"Sign up", @"sign up") forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont lm_robotoLightMessage]];
            [button addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        _forgotPasswordButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:NSLocalizedString(@"Forgot password", @"forgot password") forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont lm_robotoLightMessage]];
            [button addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
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
    
    _imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}


#pragma mark - Touch Handling

-(void) loginButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    
    NSString *username = [_username.text lowercaseString];
    NSString *password = _password.text;
    
    if ([username length] == 0 || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incomplete", @"incomplete")
                                                        message:NSLocalizedString(@"Missing credentials", @"missing credentials")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"Sign Up", @"sign up"), nil];
        [alert show];
    }
    else
    {
        [self.delegate LMUser:username pressedLoginButton:sender withPassword:password];
    }
}

-(void) signUpButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [self.delegate userPressedSignUpButton:sender];
}

-(void) forgotPasswordButtonPressed:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [self.delegate userPressedForgotPasswordButton:sender];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in @[self.username, self.password]) {
        [view resignFirstResponder];
        view.transform = CGAffineTransformIdentity;
    }
}



@end