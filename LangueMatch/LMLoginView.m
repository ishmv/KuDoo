#import "LMLoginView.h"
#import "Parse/Parse.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"

@interface LMLoginView()

@property (strong, nonatomic) UIImageView *worldView;
@property (strong, nonatomic) UILabel *langueMatchLabel;
@property (strong, nonatomic) UITextField *username;
@property (strong, nonatomic) UITextField *password;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *signUpButton;

@end

@implementation LMLoginView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _worldView = [UIImageView new];
        _worldView.image = [UIImage imageNamed:@"world_map.png"];
        _worldView.contentMode = UIViewContentModeScaleAspectFill;
        _worldView.alpha = 1.0;
        
        _langueMatchLabel = [UILabel new];
        _langueMatchLabel.font = [UIFont fontWithName:@"Didot" size:30];
        _langueMatchLabel.text = @"LangueMatch";
        _langueMatchLabel.textColor = [UIColor whiteColor];
        [[_langueMatchLabel layer] setBorderWidth:0.5];
        [[_langueMatchLabel layer] setBorderColor:[UIColor whiteColor].CGColor];
        _langueMatchLabel.textAlignment = NSTextAlignmentCenter;
        
        _username = [UITextField new];
        _username.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _username.autocorrectionType = UITextAutocorrectionTypeNo;
        _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _username.borderStyle = UITextBorderStyleRoundedRect;
        _username.placeholder = @"Username";
        _username.clearsOnBeginEditing = YES;
        [_username setFont:[UIFont lm_applicationFontLarge]];
        _username.textAlignment = NSTextAlignmentCenter;
        
        _password = [UITextField new];
        _password.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _password.autocorrectionType = UITextAutocorrectionTypeNo;
        _password.borderStyle = UITextBorderStyleRoundedRect;
        _password.secureTextEntry = YES;
        _password.textAlignment = NSTextAlignmentCenter;
        _password.clearsOnBeginEditing = YES;
        [_password setFont:[UIFont lm_applicationFontLarge]];
        _password.placeholder = @"Password";
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont lm_applicationFontLarge];
        _loginButton.backgroundColor = [UIColor clearColor];
        _loginButton.titleLabel.textColor = [UIColor whiteColor];
        _loginButton.layer.cornerRadius = 15;
        _loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _loginButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:126/255.0 blue:24/255.0 alpha:1.0];
        [[_loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_loginButton layer] setBorderWidth:1.0];
        _loginButton.clipsToBounds = YES;
        [_loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Sign Up >" forState:UIControlStateNormal];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        self.backgroundColor = [UIColor colorWithRed:109/255.0 green:132/255.0 blue:180/255.0 alpha:1.0];
        [[self layer] setShadowColor:[UIColor whiteColor].CGColor];
        self.tintColor = [UIColor blackColor];
        
        for (UIView *view in @[self.worldView, self.langueMatchLabel, self.username, self.password, self.loginButton, self.signUpButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_worldView, _langueMatchLabel, _username, _password, _loginButton, _signUpButton);
    
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
    
    CONSTRAIN_WIDTH(_username, textFieldWidth);
    CENTER_VIEW_H(self, _username);
    
    CONSTRAIN_WIDTH(_password, textFieldWidth);
    CENTER_VIEW_H(self, _password);
    
    CONSTRAIN_WIDTH(_worldView, viewWidth + 20);
    CENTER_VIEW_H(self, _worldView);
    
    CONSTRAIN_WIDTH(_loginButton, buttonWidth);
    CENTER_VIEW_H(self, _loginButton);
    
    CONSTRAIN_WIDTH(_signUpButton, buttonWidth);
    CENTER_VIEW_H(self, _signUpButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_worldView(==300)][_langueMatchLabel]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_username(==45)]-15-[_password(==45)]-15-[_loginButton(==60)]-5-[_signUpButton(==75)]-15-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
}


#pragma mark - Target Action Methods
-(void) loginButtonPressed:(UIButton *)button
{
    [self animateButtonPush:button];
    
    NSString *username = _username.text;
    NSString *password = _password.text;
    
    if ([username length] == 0 || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Password or UserName", @"No Username or Password")
                                                        message:NSLocalizedString(@"Please Enter Password/Username", @"Please Enter Password/Username")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"SignUp", nil];
        [alert show];
    }
    else
    {
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
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{button.transform = CGAffineTransformIdentity;} completion:nil];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in @[self.username, self.password]) {
        [view resignFirstResponder];
        view.transform = CGAffineTransformIdentity;
    }
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
