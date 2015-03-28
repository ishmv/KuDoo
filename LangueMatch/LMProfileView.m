#import "LMProfileView.h"
#import "Utility.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>

@interface LMProfileView()

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *fluentLanguages;
@property (nonatomic, strong) UILabel *desiredLanguage;
@property (nonatomic, strong) UIButton *startChatButton;
@property (nonatomic, strong) UIButton *changePictureButton;
@property (nonatomic, strong) UIView *bottomHalfColor;

@end

@implementation LMProfileView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        _profilePicView = [UIImageView new];
        _profilePicView.userInteractionEnabled = YES;
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTapped:)];
        [_profilePicView addGestureRecognizer:self.tapGesture];
        
        _fluentLanguages = [UILabel new];
        _fluentLanguages.textAlignment = NSTextAlignmentCenter;
        _fluentLanguages.textColor = [UIColor whiteColor];
        [[_fluentLanguages layer] setBorderWidth:0.5f];
        [[_fluentLanguages layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        
        _desiredLanguage = [UILabel new];
        _desiredLanguage.textAlignment = NSTextAlignmentCenter;
        _desiredLanguage.textColor = [UIColor whiteColor];
        _desiredLanguage.font = [UIFont applicationFontLarge];
        [[_desiredLanguage layer] setBorderWidth:0.5f];
        [[_desiredLanguage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        
        _usernameLabel = [UILabel new];
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameLabel.textAlignment = NSTextAlignmentCenter;
        _usernameLabel.font = [UIFont applicationFontLarge];
        
        _bottomHalfColor = [UIView new];
        _bottomHalfColor.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0];
        _bottomHalfColor.frame = CGRectMake(0, 200, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-200);
        
        _startChatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_startChatButton setTitle:NSLocalizedString(@"Say Hey", @"Say Hey") forState:UIControlStateNormal];
        [_startChatButton addTarget:self action:@selector(startChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _startChatButton.titleLabel.font = [UIFont applicationFontLarge];
        _startChatButton.backgroundColor = [UIColor whiteColor];
        
        // Add only if current user
        _changePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"cameraButton.png"];
        [_changePictureButton setImage:buttonImage forState:UIControlStateNormal];
        [self addMaskToImageView:_changePictureButton.imageView];
        
        self.backgroundColor =  [UIColor clearColor];
        
        for (UIView *view in @[self.bottomHalfColor, self.profilePicView, self.fluentLanguages, self.desiredLanguage, self.usernameLabel, self.changePictureButton, self.startChatButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameLabel, _profilePicView, _desiredLanguage, _fluentLanguages, _changePictureButton, _startChatButton);
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    CONSTRAIN_WIDTH(_desiredLanguage, viewWidth + 20);
    CENTER_VIEW_H(self, _desiredLanguage);
    
    CONSTRAIN_WIDTH(_fluentLanguages, viewWidth + 20);
    CENTER_VIEW_H(self, _fluentLanguages);
    
    CONSTRAIN_WIDTH(_usernameLabel, 275);
    CENTER_VIEW_H(self, _usernameLabel);
    
    CONSTRAIN_WIDTH(_profilePicView, viewWidth);
    
    CONSTRAIN_WIDTH(_changePictureButton, 50);
    CONSTRAIN_HEIGHT(_changePictureButton, 50);
    CENTER_VIEW_H(self, _changePictureButton);
    
    CONSTRAIN_WIDTH(_startChatButton, 150);
    CENTER_VIEW_H(self, _startChatButton);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_profilePicView(==200)][_usernameLabel(==40)]-30-[_fluentLanguages(==40)][_desiredLanguage(==40)]-100-[_startChatButton(==60)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_startChatButton(==50)]-100-|"
//                                                                 options:kNilOptions
//                                                                 metrics:nil
//                                                                   views:viewDictionary]];
}

#pragma mark - Setter Methods

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    BOOL isCurrentUser = ([user.objectId isEqualToString:[PFUser currentUser].objectId]) ? YES : NO;
    
    if (isCurrentUser) {

        // Tap picture to change or picture button in corner
        
        
        
    } else {
//        self.startChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [self.startChatButton setTitle:@"Start Chat" forState:UIControlStateNormal];
//        [self.startChatButton addTarget:self action:@selector(chatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:self.startChatButton];
    }
    
    _usernameLabel.text = user[PF_USER_USERNAME];
    _fluentLanguages.text = [NSString stringWithFormat:@"Fluent in: %@", user[PF_USER_FLUENT_LANGUAGE]];
    _desiredLanguage.text = [NSString stringWithFormat:@"Learning: %@", user[PF_USER_DESIRED_LANGUAGE]];

}

-(void) setProfilePic:(UIImage *)profilePic
{
    _profilePic = profilePic;
    
    self.profilePicView.image = profilePic;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    [self addMaskToImageView:_profilePicView];
}

#pragma mark - Delegate Methods

-(void)cameraButtonTapped:(UITapGestureRecognizer *)gesture
{
    [self.profileViewDelegate didTapProfileImageView:self.profilePicView];
}

-(void)updateBioButtonPressed:(UIButton *)sender
{
    [self.profileViewDelegate didTapUpdateBioButton:sender];
}

-(void)startChatButtonPressed:(UIButton *)sender
{
    [self.profileViewDelegate didTapChatButton:sender];
}

-(void) addMaskToImageView:(UIImageView *)imageView
{
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds)) radius:CGRectGetHeight(imageView.bounds)/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    imageView.layer.mask = mask;
}

@end
