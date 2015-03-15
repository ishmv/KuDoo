#import "LMSignUpView.h"
#import "QuickBlox/QBUUser.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, LMLanguage) {
    LMLanguageEnglish   =    0,
    LMLanguageSpanish   =    1,
    LMLanguageJapanese  =    3,
    LMLanguageHindi     =    4
};

@interface LMSignUpView() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UILabel *passwordLengthRequirement;
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

-(instancetype) init
{
    if (self = [super init]) {
        self.usernameField = [UITextField new];
        self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
        self.usernameField.placeholder = @"Choose a username";
        
        self.passwordField = [UITextField new];
        self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.placeholder = @"Enter a password";
        
        self.passwordLengthRequirement = [UILabel new];
        self.passwordLengthRequirement.text = @"Password must be at least 8 characters long";
        [self.passwordLengthRequirement sizeToFit];
        
        self.emailField = [UITextField new];
        self.emailField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailField.placeholder = @"email";
        
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
        
        self.signUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.usernameField, self.passwordField, self.passwordLengthRequirement, self.emailField, self.fluentLanguagePicker, self.desiredLanguagePicker, self.signUpButton, self.selectFluentLanguageLabel, self.selectDesiredLanguageLabel]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:126/255.0 blue:34/255.0 alpha:1.0];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameField, _passwordField, _passwordLengthRequirement, _emailField, _fluentLanguagePicker, _desiredLanguagePicker, _signUpButton,_selectDesiredLanguageLabel, _selectFluentLanguageLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_usernameField]-8-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_passwordField]-8-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_selectFluentLanguageLabel]-20-[_selectDesiredLanguageLabel]-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectFluentLanguageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_fluentLanguagePicker]-20-[_desiredLanguagePicker]-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_emailField]-20-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.signUpButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_usernameField][_selectFluentLanguageLabel][_fluentLanguagePicker]-15-[_passwordField]-15-[_passwordLengthRequirement]-15-[_emailField]-15-[_signUpButton]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
}

-(void)signUpButtonPressed:(UIButton *)sender
{

    QBCBlob
    
    QBUUser *user = [QBUUser user];
    user.login = _usernameField.text;
    user.password = _passwordField.text;
    user.email = _emailField.text;
    
    [self.delegate userPressedSignUpButton:sender withUserCredentials:user];
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


@end
