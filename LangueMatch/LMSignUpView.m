#import "LMSignUpView.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"

typedef NS_ENUM(NSInteger, LMLanguage) {
    LMLanguageEnglish   =    0,
    LMLanguageSpanish   =    1,
    LMLanguageJapanese  =    3,
    LMLanguageHindi     =    4
};

@interface LMSignUpView() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField1;
@property (strong, nonatomic) UITextField *passwordField2;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIPickerView *fluentLanguagePicker;
@property (strong, nonatomic) UIPickerView *desiredLanguagePicker;
@property (strong, nonatomic) UILabel *selectFluentLanguageLabel;
@property (strong, nonatomic) UILabel *selectDesiredLanguageLabel;

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
        
        self.selectFluentLanguageLabel = [UILabel new];
        self.selectFluentLanguageLabel.text = @"I am fluent in...";
        [self.selectFluentLanguageLabel sizeToFit];
        
        self.selectDesiredLanguageLabel = [UILabel new];
        self.selectDesiredLanguageLabel.text = @"And am learning ...";
        [self.selectDesiredLanguageLabel sizeToFit];
        
        self.fluentLanguagePicker = [UIPickerView new];
        self.fluentLanguagePicker.dataSource = self;
        self.fluentLanguagePicker.delegate = self;
        
        self.desiredLanguagePicker = [UIPickerView new];
        self.desiredLanguagePicker.dataSource = self;
        self.desiredLanguagePicker.delegate = self;
        
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
        
        for (UIView *view in @[self.usernameField, self.passwordField1, self.passwordField2, self.emailField, self.fluentLanguagePicker, self.desiredLanguagePicker, self.signUpButton, self.selectFluentLanguageLabel, self.selectDesiredLanguageLabel]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        self.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.5 brightness:0.5 alpha:0.3];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameField, _passwordField1, _passwordField2, _emailField, _fluentLanguagePicker, _desiredLanguagePicker, _signUpButton,_selectDesiredLanguageLabel, _selectFluentLanguageLabel);
    
    [self createWidthConstraintOnView:self.usernameField withWidth:250];
    [self centerView:self.usernameField withParentView:self];
    
    [self createWidthConstraintOnView:self.passwordField1 withWidth:250];
    [self centerView:self.passwordField1 withParentView:self];
    

    [self createWidthConstraintOnView:self.passwordField2 withWidth:250];
    [self centerView:self.passwordField2 withParentView:self];
    
    [self createWidthConstraintOnView:self.emailField withWidth:250];
    [self centerView:self.emailField withParentView:self];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectFluentLanguageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fluentLanguagePicker
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectDesiredLanguageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.desiredLanguagePicker
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectFluentLanguageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.selectDesiredLanguageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    [self createWidthConstraintOnView:self.fluentLanguagePicker withWidth:self.bounds.size.width/2];
    [self createWidthConstraintOnView:self.desiredLanguagePicker withWidth:self.bounds.size.width/2];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_fluentLanguagePicker][_desiredLanguagePicker]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fluentLanguagePicker
                                                      attribute:NSLayoutAttributeCenterY
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.desiredLanguagePicker
                                                      attribute:NSLayoutAttributeCenterY
                                                     multiplier:1
                                                       constant:0]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_signUpButton]-25-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_usernameField(==30)]-15-[_passwordField1(==30)]-15-[_passwordField2(==30)]-15-[_emailField(==30)][_selectFluentLanguageLabel][_fluentLanguagePicker]-15-[_signUpButton]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_signUpButton(==50)]-15-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
}

-(void)signUpButtonPressed:(UIButton *)sender
{
    
    [self animateButtonPush:sender];
    
    NSString *name = self.usernameField.text;
    NSString *email = self.emailField.text;
    NSString *password1 = self.passwordField1.text;
    NSString *password2 = self.passwordField2.text;
    NSInteger fluentLanguage = [self.fluentLanguagePicker selectedRowInComponent:0];
    NSInteger desiredLanguage = [self.desiredLanguagePicker selectedRowInComponent:0];
    
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
        JGProgressHUD *signingUp = [JGProgressHUD new];
        signingUp.textLabel.text = @"Signing Up";
        [signingUp showInView:self];
        [signingUp dismissAfterDelay:3.0];
        
        PFUser *user = [PFUser new];
        user.username = name;
        user.email = email;
        user.password= password2;
        user[PF_USER_FLUENT_LANGUAGE] = languages[fluentLanguage];
        user[PF_USER_DESIRED_LANGUAGE] = languages[desiredLanguage];
        
        [self.delegate PFUser:user pressedSignUpButton:sender];
    }
}

#pragma mark - UIPickerDataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [languages count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return languages[row];
}

#pragma mark -Layout helper methods
-(void)centerView:(UIView *)view withParentView:(UIView *)parent
{
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:parent
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

-(void)createWidthConstraintOnView:(UIView *)view withWidth:(CGFloat)width
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                        constant:width]];
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
