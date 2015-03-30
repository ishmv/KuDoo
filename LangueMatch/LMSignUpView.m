#import "LMSignUpView.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"

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
@property (strong, nonatomic) UITextField *passwordField1;
@property (strong, nonatomic) UITextField *passwordField2;
@property (strong, nonatomic) UITextField *emailField;

@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *fluentLanguageButton;
@property (strong, nonatomic) UIButton *desiredLanguageButton;

@property (strong, nonatomic) UILabel *chosenFluentLanguage;
@property (strong, nonatomic) UILabel *chosenDesiredLanguage;

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
        
        self.usernameField = [UITextField new];
        self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
        self.usernameField.placeholder = @"Choose a username";
        self.usernameField.font = [UIFont applicationFontSmall];
        self.usernameField.textAlignment = NSTextAlignmentCenter;
        
        self.passwordField1 = [UITextField new];
        self.passwordField1.borderStyle = UITextBorderStyleRoundedRect;
        self.passwordField1.secureTextEntry = YES;
        self.passwordField1.placeholder = @"Choose a password";
        self.passwordField1.font = [UIFont applicationFontSmall];
        self.passwordField1.textAlignment = NSTextAlignmentCenter;
        
        self.passwordField2 = [UITextField new];
        self.passwordField2.borderStyle = UITextBorderStyleRoundedRect;
        self.passwordField2.secureTextEntry = YES;
        self.passwordField2.placeholder = @"Re-enter Password";
        self.passwordField2.font = [UIFont applicationFontSmall];
        self.passwordField2.textAlignment = NSTextAlignmentCenter;
        
        self.emailField = [UITextField new];
        self.emailField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailField.placeholder = @"email";
        self.emailField.font = [UIFont applicationFontSmall];
        self.emailField.textAlignment = NSTextAlignmentCenter;
        
        self.fluentLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.fluentLanguageButton layer] setCornerRadius:10];
        self.fluentLanguageButton.backgroundColor = [UIColor blackColor];
        [self.fluentLanguageButton setTitle:@"Fluent Language" forState:UIControlStateNormal];
        [self.fluentLanguageButton addTarget:self action:@selector(fluentLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.desiredLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.desiredLanguageButton setTitle:@"Desired Language" forState:UIControlStateNormal];
        self.desiredLanguageButton.backgroundColor = [UIColor blackColor];
        [self.desiredLanguageButton addTarget:self action:@selector(desiredLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.signUpButton setTitle:@"Sign Me Up!" forState:UIControlStateNormal];
        self.signUpButton.titleLabel.font = [UIFont applicationFontLarge];
        self.signUpButton.titleLabel.textColor = [UIColor whiteColor];
        self.signUpButton.layer.cornerRadius = 15;
        self.signUpButton.clipsToBounds = YES;
        [[self.signUpButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[self.signUpButton layer] setBorderWidth:4.0];
        self.signUpButton.backgroundColor = [UIColor clearColor];
        [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.usernameField, self.passwordField1, self.passwordField2, self.emailField, self.signUpButton, self.desiredLanguageButton, self.fluentLanguageButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        self.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.5 brightness:0.5 alpha:0.6];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameField, _passwordField1, _passwordField2, _emailField, _fluentLanguageButton,_desiredLanguageButton, _signUpButton);
    
    CONSTRAIN_WIDTH(_usernameField, 250);
    CENTER_VIEW_H(self, _usernameField);
    
    CONSTRAIN_WIDTH(_passwordField1, 250);
    CENTER_VIEW_H(self, _passwordField1);
    
    CONSTRAIN_WIDTH(_passwordField2, 250);
    CENTER_VIEW_H(self, _passwordField2);

    CONSTRAIN_WIDTH(_emailField, 250);
    CENTER_VIEW_H(self, _emailField);
    
    CONSTRAIN_WIDTH(_fluentLanguageButton, 150);
    CENTER_VIEW_H(self, _fluentLanguageButton);
    
    CONSTRAIN_WIDTH(_desiredLanguageButton, 150);
    CENTER_VIEW_H(self, _desiredLanguageButton);

    CONSTRAIN_WIDTH(_signUpButton, 250);
    CENTER_VIEW_H(self, _signUpButton);

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_usernameField(==50)]-10-[_passwordField1(==40)]-15-[_passwordField2(==50)]-15-[_emailField(==50)]-15-[_fluentLanguageButton(==50)]-15-[_desiredLanguageButton(==50)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_signUpButton(==50)]-75-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
}

#pragma mark - UI Interaction

-(void)signUpButtonPressed:(UIButton *)sender
{
    
    [self animateButtonPush:sender];
    
    NSString *name = _usernameField.text;
    NSString *email = _emailField.text;
    NSString *password1 = _passwordField1.text;
    NSString *password2 = _passwordField2.text;
    NSString *fluentLanguage = _fluentLanguageButton.titleLabel.text;
    NSString *desiredLanguage = _desiredLanguageButton.titleLabel.text;
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"There was an Error Signing Up") message:NSLocalizedString(@"Check credentials", @"Please Check Credentials and try again") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (![password1 isEqualToString:password2]) {
        message.message = @"The passwords do not match";
        [message show];
    } else if (fluentLanguage == desiredLanguage) {
        message.message = @"Please select a different languages";
        [message show];
    } else if (!desiredLanguage) {
        message.message = @"Please choose a language";
        [message show];
    } else if ([email length] == 0) {
        message.message = @"Please enter a valid email";
        [message show];
    } else {

        /*
         Use loading indicator
         */
        
        PFUser *user = [PFUser new];
        user.username = name;
        user.email = email;
        user.password= password2;
        user[PF_USER_FLUENT_LANGUAGE] = fluentLanguage;
        user[PF_USER_DESIRED_LANGUAGE] = desiredLanguage;
        
        [self.delegate PFUser:user pressedSignUpButton:sender];
    }
}


-(void)fluentLanguageButtonPressed:(UIButton *)sender
{
    self.desiredLanguageButton.selected = YES;
    
    [self.delegate pressedFluentLanguageButton:sender withCompletion:^(NSString *language) {
        self.fluentLanguageButton.selected = YES;
        [self.fluentLanguageButton setTitle:language forState:UIControlStateSelected];
    }];
}

-(void) desiredLanguageButtonPressed:(UIButton *)sender
{
    self.desiredLanguageButton.selected = YES;
    
    [self.delegate pressedDesiredLanguageButton:sender withCompletion:^(NSString *language) {
        self.desiredLanguageButton.selected = YES;
        [self.desiredLanguageButton setTitle:language forState:UIControlStateSelected];
    }];
}


#pragma mark - Button Animation

-(void) animateButtonPush:(UIButton *)button
{
    button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.transform = CGAffineTransformIdentity;
    } completion:nil
     ];
}


@end
