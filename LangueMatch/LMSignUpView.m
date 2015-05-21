#import "LMSignUpView.h"

#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "Utility.h"
#import "LMAlertControllers.h"

#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface LMSignUpView()

@property (strong, nonatomic) UILabel *signUpLabel;

@property (strong, nonatomic) UIButton *addPictureButton;

@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField1;
@property (strong, nonatomic) UITextField *emailField;

@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *fluentLanguageButton;
@property (strong, nonatomic) UIButton *desiredLanguageButton;
@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) UIButton *haveAccountButton;

@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) CALayer *imageLayer;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation LMSignUpView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor lm_wetAsphaltColor];
        
        _imageLayer = [CALayer layer];
        _imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        _imageLayer.contents = (id)[UIImage imageNamed:@"1.jpg"].CGImage;
        [self.layer insertSublayer:_imageLayer atIndex:1];
        
        _gradientLayer = ({
            CAGradientLayer *layer = [[CAGradientLayer alloc] init];
            layer.colors = @[(id)[UIColor lm_peterRiverColor].CGColor, (id)[[UIColor lm_orangeColor] colorWithAlphaComponent:0.8f].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:1.0f] .CGColor];
            layer.opacity = 1.0f;
            layer;
        });
        
        [[self layer] insertSublayer:_gradientLayer above:_imageLayer];
        [[self layer] setShadowColor:[UIColor whiteColor].CGColor];
        
        _signUpLabel = [[UILabel alloc] init];
        [_signUpLabel setText:@"Sign Up"];
        [_signUpLabel setFont:[UIFont lm_chalkboardSELightLarge]];
        [_signUpLabel setTextColor:[UIColor whiteColor]];
        
        UIImage *blankProfileImage = [UIImage imageNamed:@"empty_profile.png"];
        _profileImageView = [[UIImageView alloc] initWithImage:blankProfileImage];
        _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _profileImageView.frame = CGRectMake(0, 0, 100, 100);
        [_profileImageView setUserInteractionEnabled:YES];
        
        UIBezierPath *clippingPath= [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.profileImageView.frame.size.width/2, self.profileImageView.frame.size.height/2) radius:CGRectGetHeight(_profileImageView.frame)/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = clippingPath.CGPath;
        [_profileImageView.layer setMask:mask];
        [_profileImageView.layer setMasksToBounds:YES];
        
        _addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *polaroid = [UIImage imageNamed:@"camera"];
        [_addPictureButton setImage:polaroid forState:UIControlStateNormal];
        _addPictureButton.frame = CGRectMake(0, 0, 30, 30);
        [_addPictureButton addTarget:self action:@selector(profileImageViewTapped:) forControlEvents:UIControlEventTouchUpInside];

        _usernameField = [[UITextField alloc] init];
        _usernameField.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _usernameField.borderStyle = UITextBorderStyleNone;
        [_usernameField setBackgroundColor:[UIColor clearColor]];
        _usernameField.clearsOnBeginEditing = NO;
        _usernameField.font = [UIFont lm_chalkboardSELightLarge];
        _usernameField.textAlignment = NSTextAlignmentRight;
        _usernameField.placeholder = @"username";
        _usernameField.textColor = [UIColor whiteColor];
        
        UIImage *carImage = [UIImage imageNamed:@"pig.png"];
        UIImageView *carImageView = [[UIImageView alloc] initWithImage:carImage];
        carImageView.contentMode = UIViewContentModeCenter;
        [_usernameField leftViewRectForBounds:CGRectMake(0, 0, 30, 30)];
        [_usernameField setLeftView:carImageView];
        [_usernameField setLeftViewMode:UITextFieldViewModeAlways];
        
        _passwordField1 = [[UITextField alloc] init];
        _passwordField1.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _passwordField1.borderStyle = UITextBorderStyleNone;
        _passwordField1.secureTextEntry = YES;
        [_passwordField1 setBackgroundColor:[UIColor clearColor]];
        _passwordField1.placeholder = @"password";
        _passwordField1.font = [UIFont lm_chalkboardSELightLarge];
        _passwordField1.textAlignment = NSTextAlignmentRight;
        _passwordField1.textColor = [UIColor whiteColor];
        
        UIImage *lockImage = [UIImage imageNamed:@"barricade.png"];
        UIImageView *lockImageView = [[UIImageView alloc] initWithImage:lockImage];
        lockImageView.contentMode = UIViewContentModeCenter;
        [_passwordField1 leftViewRectForBounds:CGRectMake(0, 0, 30, 30)];
        [_passwordField1 setLeftView:lockImageView];
        [_passwordField1 setLeftViewMode:UITextFieldViewModeAlways];
        
        _emailField = [[UITextField alloc] init];
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.keyboardAppearance = UIKeyboardTypeEmailAddress;
        _emailField.borderStyle = UITextBorderStyleNone;
        _emailField.backgroundColor = [UIColor clearColor];
        _emailField.placeholder = @"email";
        _emailField.font = [UIFont lm_chalkboardSELightLarge];
        _emailField.textAlignment = NSTextAlignmentRight;
        _emailField.textColor = [UIColor whiteColor];
        
        UIImage *messageImage = [UIImage imageNamed:@"folder.png"];
        UIImageView *messageImageView = [[UIImageView alloc] initWithImage:messageImage];
        messageImageView.contentMode = UIViewContentModeCenter;
        [_emailField leftViewRectForBounds:CGRectMake(0, 0, 30, 30)];
        [_emailField setLeftView:messageImageView];
        [_emailField setLeftViewMode:UITextFieldViewModeAlways];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 3)];
        [_lineView setBackgroundColor:[UIColor whiteColor]];
        
        
        _fluentLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *lights = [UIImage imageNamed:@"lights.png"];
        UIImageView *lightsImageView = [[UIImageView alloc] initWithImage:lights];
        lightsImageView.frame = CGRectMake(0, 13, 30, 30);
        lightsImageView.contentMode = UIViewContentModeCenter;
        [_fluentLanguageButton addSubview:lightsImageView];

        _fluentLanguageButton.backgroundColor = [UIColor clearColor];
        [_fluentLanguageButton.titleLabel setTextColor:[UIColor clearColor]];
        [_fluentLanguageButton.titleLabel setFont:[UIFont lm_chalkboardSELightLarge]];
        [_fluentLanguageButton setTitle:@"Native Language" forState:UIControlStateNormal];
        [_fluentLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_fluentLanguageButton addTarget:self action:@selector(fluentLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _desiredLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *lightsImageView1 = [[UIImageView alloc] initWithImage:lights];
        lightsImageView1.frame = CGRectMake(0, 13, 30, 30);
        lightsImageView1.contentMode = UIViewContentModeCenter;
        [[_desiredLanguageButton layer] setCornerRadius:10];
        [_desiredLanguageButton addSubview:lightsImageView1];
        [_desiredLanguageButton setTitle:@"Desired Language" forState:UIControlStateNormal];
        [_desiredLanguageButton.titleLabel setFont:[UIFont lm_chalkboardSELightLarge]];
        _desiredLanguageButton.backgroundColor = [UIColor clearColor];
        [_desiredLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_desiredLanguageButton addTarget:self action:@selector(desiredLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUpButton setTitle:@"Sign-Up" forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont lm_chalkboardSELightLarge];
        [_signUpButton setTitleColor:[UIColor lm_wetAsphaltColor] forState:UIControlStateNormal];
        [[_signUpButton layer] setCornerRadius:5];
        _signUpButton.backgroundColor = [UIColor lm_cloudsColor];
        [_signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _facebookLoginButton = [[FBSDKLoginButton alloc] init];
        [_facebookLoginButton addTarget:self action:@selector(facebookButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _haveAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_haveAccountButton setTitle:@"Already have an account? Login" forState:UIControlStateNormal];
        [_haveAccountButton setBackgroundColor:[UIColor clearColor]];
        [_haveAccountButton.titleLabel setFont:[UIFont lm_chalkboardSELightSmall]];
        [_haveAccountButton addTarget:self action:@selector(haveAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.signUpLabel, self.profileImageView, self.usernameField, self.passwordField1, self.emailField, self.lineView, self.signUpButton, self.desiredLanguageButton, self.fluentLanguageButton, self.facebookLoginButton, self.haveAccountButton, self.addPictureButton])
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

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_signUpLabel,_profileImageView, _usernameField, _passwordField1, _emailField, _lineView, _fluentLanguageButton,_desiredLanguageButton, _signUpButton, _facebookLoginButton, _haveAccountButton);
    
    CGFloat buttonWidth;
    CGFloat textFieldWidth;
    
    if (IS_IPHONE)
    {
        buttonWidth = 315;
        textFieldWidth = 315;
    }
    else if (IS_IPAD)
    {
        buttonWidth = 400;
        textFieldWidth = 400;
    }
    
    CENTER_VIEW_H(self, _signUpLabel);
    
    CONSTRAIN_HEIGHT(_profileImageView, 100);
    CONSTRAIN_WIDTH(_profileImageView, 100);
    CENTER_VIEW_H(self, _profileImageView);
    
    ALIGN_VIEW_TOP_CONSTANT(self, _addPictureButton, 60);
    ALIGN_VIEW_LEFT_CONSTANT(self, _addPictureButton, self.frame.size.width/2 + 50);
    
    CONSTRAIN_WIDTH(_usernameField, textFieldWidth);
    CENTER_VIEW_H(self, _usernameField);
    
    CONSTRAIN_WIDTH(_passwordField1, textFieldWidth);
    CENTER_VIEW_H(self, _passwordField1);

    CONSTRAIN_WIDTH(_emailField, textFieldWidth);
    CENTER_VIEW_H(self, _emailField);
    
    CONSTRAIN_WIDTH(_lineView, buttonWidth);
    CENTER_VIEW_H(self, _lineView);
    
    CONSTRAIN_WIDTH(_fluentLanguageButton, buttonWidth);
    CENTER_VIEW_H(self, _fluentLanguageButton);
    
    CONSTRAIN_WIDTH(_desiredLanguageButton, buttonWidth);
    CENTER_VIEW_H(self, _desiredLanguageButton);

    CONSTRAIN_WIDTH(_signUpButton, buttonWidth);
    CENTER_VIEW_H(self, _signUpButton);
    
    CONSTRAIN_WIDTH(_facebookLoginButton, buttonWidth);
    CENTER_VIEW_H(self, _facebookLoginButton);

    CONSTRAIN_WIDTH(_haveAccountButton, buttonWidth);
    CENTER_VIEW_H(self, _haveAccountButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[_signUpLabel]-10-[_profileImageView]-15-[_usernameField(==40)][_passwordField1(==40)][_emailField(==40)]-15-[_lineView(==1)]-20-[_fluentLanguageButton(==50)]-15-[_desiredLanguageButton(==50)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_signUpButton(==50)]-15-[_facebookLoginButton(==50)]-8-[_haveAccountButton(==60)]-8-|"
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
    
    NSString *name = _usernameField.text;
    NSString *email = _emailField.text;
    NSString *password1 = _passwordField1.text;
    NSString *fluentLanguage = [_fluentLanguageButton.titleLabel.text lowercaseString];
    NSString *desiredLanguage = [_desiredLanguageButton.titleLabel.text lowercaseString];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"There was an Error Signing Up") message:NSLocalizedString(@"Check credentials", @"Please Check Credentials and try again") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (password1.length == 0)
    {
        message.message = @"Hey you don't want intruders hacking your identity do ya?";
        [message show];
    }
    else if (fluentLanguage == desiredLanguage)
    {
        message.message = @"Hey I want to learn Desired Language to!";
        [message show];
    }
    else if ([desiredLanguage isEqualToString:@"Desired Language"] || [fluentLanguage isEqualToString:@"Fluent Language"])
    {
        message.message = @"Looks like you are already fluent in that language...";
        [message show];
    }
    else if ([email length] == 0)
    {
        message.message = @"How would we contact you if you forget your password?!?!";
        [message show];
    }

    else
    {
        PFUser *user = [PFUser new];
        user.username = name;
        user[PF_USER_USERNAME_LOWERCASE] = [name lowercaseString];
        user.email = email;
        user[PF_USER_EMAILCOPY] = [email lowercaseString];
        user.password = password1;
        user[PF_USER_FLUENT_LANGUAGE] = fluentLanguage;
        user[PF_USER_DESIRED_LANGUAGE] = desiredLanguage;
        user[PF_USER_AVAILABILITY] = @(YES);
        
        UIImage *profileImage = self.profileImageView.image;
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.9);
        PFFile *imageFile = [PFFile fileWithName:@"picture" data:imageData];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(70, 70), NO, 0.0);
        [profileImage drawInRect:CGRectMake(0, 0, 70, 70)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *thumbnailData = UIImageJPEGRepresentation(newImage, 1.0);
        PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail" data:thumbnailData];
        
        user[@"picture"] = imageFile;
        user[@"thumbnail"] = thumbnailFile;
        
        [self.delegate PFUser:user pressedSignUpButton:sender];
    }
}


-(void) facebookButtonPressed:(UIButton *)sender
{
    NSString *fluentLanguage = [_fluentLanguageButton.titleLabel.text lowercaseString];
    NSString *desiredLanguage = [_desiredLanguageButton.titleLabel.text lowercaseString];
    
    NSDictionary *languageChoices = @{PF_USER_FLUENT_LANGUAGE : fluentLanguage, PF_USER_DESIRED_LANGUAGE : desiredLanguage};
    
    [self.delegate userPressedFacebookButtonWithLanguagePreferences:languageChoices];
}

-(void)fluentLanguageButtonPressed:(UIButton *)sender
{
    [self animateButtonPush:sender];
    
    [self.delegate pressedFluentLanguageButton:sender withCompletion:^(NSString *language) {
        self.fluentLanguageButton.selected = YES;
        [self.fluentLanguageButton setTitle:[NSString stringWithFormat:@"%@", language] forState:UIControlStateSelected];
    }];
}

-(void) desiredLanguageButtonPressed:(UIButton *)sender
{
    [self animateButtonPush:sender];
    
    [self.delegate pressedDesiredLanguageButton:sender withCompletion:^(NSString *language) {
        self.desiredLanguageButton.selected = YES;
        [self.desiredLanguageButton setTitle:[NSString stringWithFormat:@"%@", language] forState:UIControlStateSelected];
    }];
}

-(void) profileImageViewTapped:(UIButton *)button
{
    [self.delegate profileImageViewSelected:_profileImageView];
}

-(void) haveAccountButtonTapped:(UIButton *)button
{
    [self.delegate hasAccountButtonPressed];
}

#pragma mark - Setter Methods

-(void)setProfileImage:(UIImage *)profileImage
{
    _profileImageView.image = profileImage;
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
    [_emailField resignFirstResponder];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSLog(@"Called");
}

@end
