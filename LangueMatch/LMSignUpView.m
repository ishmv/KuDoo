#import "LMSignUpView.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "LMUsers.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, LMLanguage) {
    LMLanguageEnglish   =    0,
    LMLanguageSpanish   =    1,
    LMLanguageJapanese  =    3,
    LMLanguageHindi     =    4
};

@interface LMSignUpView()

@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UILabel *usernameLabel;

@property (strong, nonatomic) UITextField *passwordField1;
@property (strong, nonatomic) UITextField *passwordField2;
@property (strong, nonatomic) UITextField *emailField;

@property (strong, nonatomic) UIButton *signUpButton;

@property (strong, nonatomic) UIButton *fluentLanguageButton;
@property (strong, nonatomic) UILabel *fluentLanguageLabel;

@property (strong, nonatomic) UIButton *desiredLanguageButton;
@property (strong, nonatomic) UIButton *facebookLoginButton;

@end

@implementation LMSignUpView

static NSArray *languages;

+(void)load
{
    languages = @[@"English", @"Spanish", @"Japanese", @"Hindi"];
}

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        
        _usernameField = [UITextField new];
        _usernameField.borderStyle = UITextBorderStyleRoundedRect;
        _usernameField.clearsOnBeginEditing = NO;
        _usernameField.font = [UIFont applicationFontSmall];
        _usernameField.textAlignment = NSTextAlignmentCenter;
        
        _usernameLabel = [UILabel new];
        [_usernameLabel setText:@"Username"];
        _usernameLabel.textColor = [UIColor blackColor];
        [_usernameLabel sizeToFit];
        _usernameLabel.font = [UIFont fontWithName:@"GillSans-Light" size:12];
        _usernameLabel.textColor = [UIColor lightGrayColor];
        _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_usernameField addSubview:_usernameLabel];
        
        _passwordField1 = [UITextField new];
        _passwordField1.borderStyle = UITextBorderStyleRoundedRect;
        _passwordField1.secureTextEntry = YES;
        _passwordField1.placeholder = @"Choose a password";
        _passwordField1.font = [UIFont applicationFontSmall];
        _passwordField1.textAlignment = NSTextAlignmentCenter;
        
        _passwordField2 = [UITextField new];
        _passwordField2.borderStyle = UITextBorderStyleRoundedRect;
        _passwordField2.secureTextEntry = YES;
        _passwordField2.placeholder = @"Re-enter Password";
        _passwordField2.font = [UIFont applicationFontSmall];
        _passwordField2.textAlignment = NSTextAlignmentCenter;
        
        _emailField = [UITextField new];
        _emailField.borderStyle = UITextBorderStyleRoundedRect;
        _emailField.placeholder = @"email";
        _emailField.font = [UIFont applicationFontSmall];
        _emailField.textAlignment = NSTextAlignmentCenter;
        
        _fluentLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[_fluentLanguageButton layer] setCornerRadius:10];
        _fluentLanguageButton.backgroundColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1.0];
        [_fluentLanguageButton setTitle:@"Fluent Language" forState:UIControlStateNormal];
        [_fluentLanguageButton addTarget:self action:@selector(fluentLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _fluentLanguageLabel = [UILabel new];
        [_fluentLanguageLabel setText:@"Fluent Language"];
        _fluentLanguageLabel.textColor = [UIColor blackColor];
        [_fluentLanguageLabel sizeToFit];
        _fluentLanguageLabel.font = [UIFont fontWithName:@"GillSans-Light" size:12];
        _fluentLanguageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_fluentLanguageButton addSubview:_fluentLanguageLabel];
        
        _desiredLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[_desiredLanguageButton layer] setCornerRadius:10];
        [_desiredLanguageButton setTitle:@"Desired Language" forState:UIControlStateNormal];
        _desiredLanguageButton.backgroundColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1.0];
        [_desiredLanguageButton addTarget:self action:@selector(desiredLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Sign Me Up!" forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont applicationFontLarge];
        _signUpButton.titleLabel.textColor = [UIColor whiteColor];
        _signUpButton.layer.cornerRadius = 15;
        _signUpButton.clipsToBounds = YES;
        [[_signUpButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_signUpButton layer] setBorderWidth:1.0];
        _signUpButton.backgroundColor = [UIColor colorWithRed:230/255.0 green:126/255.0 blue:24/255.0 alpha:1.0];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //Look Into
//        _facebookLoginButton = [[FBSDKButton alloc] init];
        
        _facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_facebookLoginButton setTitle:@"Sign In With Facebook" forState:UIControlStateNormal];
        _facebookLoginButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        _facebookLoginButton.titleLabel.textColor = [UIColor whiteColor];
        _facebookLoginButton.layer.cornerRadius = 15;
        _facebookLoginButton.clipsToBounds = YES;
        _facebookLoginButton.backgroundColor = [UIColor colorWithRed:109/255.0 green:132/255.0 blue:180/255.0 alpha:1.0];
        [[_facebookLoginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_facebookLoginButton layer] setBorderWidth:1.0];
        [_facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.usernameField, self.passwordField1, self.passwordField2, self.emailField, self.signUpButton, self.desiredLanguageButton, self.fluentLanguageButton, self.facebookLoginButton]) {
            
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        self.backgroundColor = [UIColor colorWithRed:109/255.0 green:132/255.0 blue:180/255.0 alpha:1.0];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameField, _passwordField1, _passwordField2, _emailField, _fluentLanguageButton,_desiredLanguageButton, _signUpButton, _facebookLoginButton);
    
    CGFloat buttonWidth;
    CGFloat textFieldWidth;
    
    if (IS_IPHONE)
    {
        buttonWidth = 275;
        textFieldWidth = 275;
    }
    else if (IS_IPAD)
    {
        buttonWidth = 400;
        textFieldWidth = 400;
    }
    
    CONSTRAIN_WIDTH(_usernameField, textFieldWidth);
    CENTER_VIEW_H(self, _usernameField);
    
    CENTER_VIEW_V(_usernameField, _usernameLabel);
    ALIGN_VIEW_LEFT_CONSTANT(_usernameField, _usernameLabel, 8);
    
    CONSTRAIN_WIDTH(_passwordField1, textFieldWidth);
    CENTER_VIEW_H(self, _passwordField1);
    
    CONSTRAIN_WIDTH(_passwordField2, textFieldWidth);
    CENTER_VIEW_H(self, _passwordField2);

    CONSTRAIN_WIDTH(_emailField, textFieldWidth);
    CENTER_VIEW_H(self, _emailField);
    
    CONSTRAIN_WIDTH(_fluentLanguageButton, buttonWidth);
    CENTER_VIEW_H(self, _fluentLanguageButton);
    
    CENTER_VIEW_V(_fluentLanguageButton, _fluentLanguageLabel);
    ALIGN_VIEW_LEFT_CONSTANT(_fluentLanguageButton, _fluentLanguageLabel, 8);
    
    CONSTRAIN_WIDTH(_desiredLanguageButton, buttonWidth);
    CENTER_VIEW_H(self, _desiredLanguageButton);

    CONSTRAIN_WIDTH(_signUpButton, buttonWidth);
    CENTER_VIEW_H(self, _signUpButton);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_usernameField(==50)]-10-[_passwordField1(==50)]-15-[_passwordField2(==50)]-15-[_emailField(==50)]-15-[_fluentLanguageButton(==50)]-15-[_desiredLanguageButton(==50)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_signUpButton(==50)]-15-[_facebookLoginButton(==50)]-70-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
}

#pragma mark - Target/Action

-(void)signUpButtonPressed:(UIButton *)sender
{
    [self animateButtonPush:sender];
    
    NSString *name = _usernameField.text;
    NSString *email = _emailField.text;
    NSString *password1 = _passwordField1.text;
    NSString *password2 = _passwordField2.text;
    NSString *fluentLanguage = [_fluentLanguageButton.titleLabel.text lowercaseString];
    NSString *desiredLanguage = [_desiredLanguageButton.titleLabel.text lowercaseString];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"There was an Error Signing Up") message:NSLocalizedString(@"Check credentials", @"Please Check Credentials and try again") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (![password1 isEqualToString:password2])
    {
        message.message = @"The passwords do not match";
        [message show];
    }
    else if (fluentLanguage == desiredLanguage)
    {
        message.message = @"Please select a different languages";
        [message show];
    }
    else if ([desiredLanguage isEqualToString:@"Desired Language"])
    {
        message.message = @"Please choose the language you would like to learn";
        [message show];
    }
    else if ([email length] == 0)
    {
        message.message = @"Please enter a valid email";
        [message show];
    }
    else if ([fluentLanguage isEqualToString:@"Fluent Language"])
    {
        message.message = @"Please choose your native langauge";
        [message show];
    }
    else
    {
        PFUser *user = [PFUser new];
        user.username = name;
        user[PF_USER_USERNAME_LOWERCASE] = [name lowercaseString];
        user.email = email;
        user[PF_USER_EMAILCOPY] = [email lowercaseString];
        user.password= password2;
        user[PF_USER_FLUENT_LANGUAGE] = fluentLanguage;
        user[PF_USER_DESIRED_LANGUAGE] = desiredLanguage;
        
        [self.delegate PFUser:user pressedSignUpButton:sender];
    }
}

-(void) facebookButtonPressed:(UIButton *)sender
{
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            
            [alert show];
            
        } else {
            if (user.isNew) {
                
                if ([FBSDKAccessToken currentAccessToken]) {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error)
                        {
                            NSDictionary *userData = (NSDictionary *)result;
                            
                            NSString *facebookID = userData[@"id"];
                            NSString *fullName = userData[@"name"];
                            NSString *email = userData[@"email"];
                            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                            
                            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                            [NSURLConnection sendAsynchronousRequest:urlRequest
                                                               queue:[NSOperationQueue mainQueue]
                                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                       
                                                       UIImage *profileImage = [UIImage imageWithData:data];
                                                       [[LMUsers sharedInstance] saveUserProfileImage:profileImage];
                                                   }];
                            
                            user[PF_USER_EMAIL] = email;
                            user[PF_USER_USERNAME] = fullName;
                            [user saveInBackground];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                            message:@"LangueMatch is linked with your Facebook account"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"COOL!"
                                                                  otherButtonTitles: nil];
                            [alert show];
                            
                            [self.delegate userSignedUpWithFacebookAccount];
                        }
                    }];
                }
                
                NSLog(@"User with facebook signed up and logged in!");
//                [self.delegate userSignedUpWithFacebookAccount];
                
            } else {
                NSLog(@"User with facebook logged in!");
            }
        }
    }];
}

-(void)fluentLanguageButtonPressed:(UIButton *)sender
{
    self.desiredLanguageButton.selected = YES;
    
    [self.delegate pressedFluentLanguageButton:sender withCompletion:^(NSString *language) {
        self.fluentLanguageButton.selected = YES;
        [self.fluentLanguageButton setTitle:[NSString stringWithFormat:@"%@", language] forState:UIControlStateSelected];
    }];
}

-(void) desiredLanguageButtonPressed:(UIButton *)sender
{
    self.desiredLanguageButton.selected = YES;
    
    [self.delegate pressedDesiredLanguageButton:sender withCompletion:^(NSString *language) {
        self.desiredLanguageButton.selected = YES;
        [self.desiredLanguageButton setTitle:[NSString stringWithFormat:@"%@", language] forState:UIControlStateSelected];
    }];
}


#pragma mark - Button Animation

-(void) animateButtonPush:(UIButton *)button
{
    button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.transform = CGAffineTransformIdentity;
    } completion:nil
     ];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_usernameField resignFirstResponder];
    [_passwordField1 resignFirstResponder];
    [_passwordField2 resignFirstResponder];
    [_emailField resignFirstResponder];
}


@end
