#import "LMLoginView.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"

#import <Parse/Parse.h>

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
        
        _gradientLayer = ({
            CAGradientLayer *layer = [[CAGradientLayer alloc] init];
            layer.colors = @[(id)[[UIColor lm_wetAsphaltColor] colorWithAlphaComponent:1.0f] .CGColor, (id)[[UIColor lm_peterRiverColor] colorWithAlphaComponent:0.1f].CGColor];
            layer;
        });
        [self.layer insertSublayer:_gradientLayer atIndex:0];
        
        _imageLayer = ({
            CALayer *layer = [CALayer layer];
            layer.contents = (id)[UIImage imageNamed:@"HomeScreen.jpg"].CGImage;
            layer;
        });
        [self.layer insertSublayer:_imageLayer above:_gradientLayer];
        
        _langueMatchLabel = [UILabel new];
        _langueMatchLabel.font = [UIFont lm_chalkdusterTitle];
        _langueMatchLabel.text = @"LangueMatch";
        _langueMatchLabel.textColor = [UIColor lm_tealColor];
        _langueMatchLabel.textAlignment = NSTextAlignmentCenter;
        
        _langueMatchSlogan = [UILabel new];
        _langueMatchSlogan.font = [UIFont lm_chalkboardSELightSmall];
        _langueMatchSlogan.text = @"- A Language Tutor For Everyone -";
        _langueMatchSlogan.textColor = [UIColor whiteColor];
        _langueMatchSlogan.textAlignment = NSTextAlignmentCenter;
        
        _username = [UITextField new];
        _username.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _username.autocorrectionType = UITextAutocorrectionTypeNo;
        _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _username.borderStyle = UITextBorderStyleNone;
        _username.placeholder = @"Username";
        _username.clearsOnBeginEditing = YES;
        [_username setFont:[UIFont lm_chalkboardSELightLarge]];
        _username.textAlignment = NSTextAlignmentCenter;
        
        _password = [UITextField new];
        _password.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _password.autocorrectionType = UITextAutocorrectionTypeNo;
        _password.borderStyle = UITextBorderStyleNone;
        _password.secureTextEntry = YES;
        _password.textAlignment = NSTextAlignmentCenter;
        _password.clearsOnBeginEditing = YES;
        [_password setFont:[UIFont lm_chalkboardSELightLarge]];
        _password.placeholder = @"Password";
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont lm_chalkboardSELightLarge];
        _loginButton.backgroundColor = [UIColor clearColor];
        _loginButton.titleLabel.textColor = [UIColor whiteColor];
        _loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _loginButton.backgroundColor = [UIColor lm_silverColor];
        [_loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [_signUpButton.titleLabel setFont:[UIFont lm_chalkboardSELightSmall]];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPasswordButton setTitle:@"Forgot Password" forState:UIControlStateNormal];
        [_forgotPasswordButton.titleLabel setFont:[UIFont lm_chalkboardSELightSmall]];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonSeparator = [[UILabel alloc] init];
        [_buttonSeparator setText:@"|"];
        [_buttonSeparator setTextColor:[UIColor whiteColor]];
        
        
        self.backgroundColor = [UIColor lm_wetAsphaltColor];
        [[self layer] setShadowColor:[UIColor whiteColor].CGColor];
        self.tintColor = [UIColor blackColor];
        
        for (UIView *view in @[self.langueMatchSlogan, self.langueMatchLabel, self.username, self.password, self.loginButton, self.signUpButton, self.buttonSeparator, self.forgotPasswordButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
        buttonWidth = 300;
        textFieldWidth = 300;
    }
    else if (IS_IPAD)
    {
        buttonWidth = 400;
        textFieldWidth = 400;
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
    
    CONSTRAIN_WIDTH(_signUpButton, viewWidth/2 - 15);
    ALIGN_VIEW_RIGHT_CONSTANT(self, _signUpButton, -15);
    
    CONSTRAIN_WIDTH(_forgotPasswordButton, viewWidth/2 - 15);
    ALIGN_VIEW_LEFT_CONSTANT(self, _forgotPasswordButton, 15);
    ALIGN_VIEW_BOTTOM(self, _forgotPasswordButton);
    CONSTRAIN_HEIGHT(_forgotPasswordButton, 50);
    
    CENTER_VIEW_H(self, _buttonSeparator);
    ALIGN_VIEW_BOTTOM_CONSTANT(self, _buttonSeparator, -15);
        
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-315-[_langueMatchLabel]-15-[_langueMatchSlogan]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_username(==45)]-8-[_password(==45)]-8-[_loginButton(==60)]-5-[_signUpButton(==50)]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];

    self.gradientLayer.frame = CGRectMake(0, 300, CGRectGetWidth(self.bounds), CGRectGetHeight(self.frame) - 300);
    self.imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 300);
}


#pragma mark - Touch Handling

-(void) loginButtonPressed:(UIButton *)button
{
    [self animateButtonPush:button];
    
    NSString *username = _username.text;
    NSString *password = _password.text;
    
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

#pragma mark - UIKeyboard Notification
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    if ([_username isFirstResponder]) {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _username.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
        } completion:nil];
    } else if ([_password isFirstResponder]) {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _password.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight - 60);
        } completion:nil];
    }
}

-(void) keyboardWillHide:(NSNotification *)notification
{
    if ([_username isFirstResponder])
    {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _username.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else if ([_password isFirstResponder])
    {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _password.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    
}
@end
