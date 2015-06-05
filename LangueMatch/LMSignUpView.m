#import "LMSignUpView.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "LMAlertControllers.h"

#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <Parse/Parse.h>

@interface LMSignUpView()

@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;

@property (strong, nonatomic) UILabel *orLabel;

@end

@implementation LMSignUpView

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
        
        _signUpLabel = [[UILabel alloc] init];
        [_signUpLabel setText:@"Signup"];
        [_signUpLabel setFont:[UIFont lm_noteWorthyLarge]];
        [_signUpLabel setTextColor:[UIColor whiteColor]];

        _usernameField = [[UITextField alloc] init];
        _usernameField.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _usernameField.borderStyle = UITextBorderStyleRoundedRect;
        [_usernameField setBackgroundColor:[[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f]];
        _usernameField.clearsOnBeginEditing = NO;
        _usernameField.font = [UIFont lm_noteWorthyMedium];
        _usernameField.textAlignment = NSTextAlignmentLeft;
        _usernameField.placeholder = @"username";
        _usernameField.textColor = [UIColor whiteColor];
        
        _passwordField = [[UITextField alloc] init];
        _passwordField.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _passwordField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordField.secureTextEntry = YES;
        [_passwordField setBackgroundColor:[[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f]];
        _passwordField.placeholder = @"password";
        _passwordField.font = [UIFont lm_noteWorthyMedium];
        _passwordField.textAlignment = NSTextAlignmentLeft;
        _passwordField.textColor = [UIColor whiteColor];
        
        _emailField = [[UITextField alloc] init];
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _emailField.borderStyle = UITextBorderStyleRoundedRect;
        _emailField.backgroundColor = [[UIColor lm_cloudsColor] colorWithAlphaComponent:0.2f];
        _emailField.placeholder = @"email";
        _emailField.font = [UIFont lm_noteWorthyMedium];
        _emailField.textAlignment = NSTextAlignmentLeft;
        _emailField.textColor = [UIColor whiteColor];
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont lm_noteWorthyMedium];
        [_signUpButton setTitleColor:[UIColor lm_wetAsphaltColor] forState:UIControlStateNormal];
        [[_signUpButton layer] setCornerRadius:5];
        _signUpButton.backgroundColor = [UIColor lm_cloudsColor];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _orLabel = [[UILabel alloc] init];
        [_orLabel setText:@"Or..."];
        [_orLabel setFont:[UIFont lm_noteWorthyMedium]];
        [_orLabel setTextColor:[UIColor whiteColor]];
        
        _facebookLoginButton = [[FBSDKLoginButton alloc] init];
        [_facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _haveAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_haveAccountButton setTitle:@"Already have an account? Login" forState:UIControlStateNormal];
        [_haveAccountButton setBackgroundColor:[UIColor clearColor]];
        [_haveAccountButton.titleLabel setFont:[UIFont lm_chalkboardSELightSmall]];
        [_haveAccountButton addTarget:self action:@selector(haveAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.signUpLabel, self.usernameField, self.passwordField, self.emailField, self.signUpButton, self.orLabel, self.facebookLoginButton, self.haveAccountButton])
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

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_signUpLabel, _usernameField, _passwordField, _emailField, _signUpButton, _orLabel, _facebookLoginButton, _haveAccountButton);
    
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
    
    CONSTRAIN_WIDTH(_usernameField, textFieldWidth);
    CENTER_VIEW_H(self, _usernameField);
    
    CONSTRAIN_WIDTH(_passwordField, textFieldWidth);
    CENTER_VIEW_H(self, _passwordField);

    CONSTRAIN_WIDTH(_emailField, textFieldWidth);
    CENTER_VIEW_H(self, _emailField);

    CONSTRAIN_WIDTH(_signUpButton, buttonWidth);
    CENTER_VIEW_H(self, _signUpButton);
    
    CENTER_VIEW_H(self, _orLabel);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);

    CONSTRAIN_WIDTH(_haveAccountButton, buttonWidth);
    CENTER_VIEW_H(self, _haveAccountButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_signUpLabel]-30-[_usernameField(==45)]-2-[_passwordField(==45)]-2-[_emailField(==45)]-15-[_signUpButton(==55)]-8-[_haveAccountButton(==30)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_orLabel]-10-[_facebookLoginButton(==50)]-15-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    _gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _imageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - Touch Handling

-(void)signUpButtonPressed:(UIButton *)sender
{
    [self animateButtonPush:sender];
    
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
        NSDictionary *userCredentials = @{PF_USER_USERNAME : username, PF_USER_EMAIL : email, PF_USER_PASSWORD : password};
        [self.delegate userWithCredentials:userCredentials pressedSignUpButton:sender];
    }
}


-(void) facebookButtonPressed:(UIButton *)sender
{
    [self.delegate facebookButtonPressed:sender];
}


-(void) haveAccountButtonTapped:(UIButton *)button
{
    [self.delegate hasAccountButtonPressed];
}



#pragma mark - Button Animation

-(void) animateButtonPush:(UIButton *)sender
{
    sender.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.transform = CGAffineTransformIdentity;
    } completion:nil
     ];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_emailField resignFirstResponder];
}

@end
