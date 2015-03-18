#import "LMProfileView.h"

@interface LMProfileView()

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UITextView *aboutMeLabel;
@property (nonatomic, strong) UIButton *updateDescriptionButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation LMProfileView

-(instancetype) init
{
    self = [super init];
    
    if (self) {
        self.profilePicView = [UIImageView new];
        self.profilePicView.userInteractionEnabled = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTapped:)];
        [self.profilePicView addGestureRecognizer:self.tapGesture];
        
        self.aboutMeLabel = [UITextView new];
        self.aboutMeLabel.backgroundColor = [UIColor clearColor];
        self.aboutMeLabel.textAlignment = NSTextAlignmentCenter;
        self.aboutMeLabel.textColor = [UIColor whiteColor];
        
        self.backgroundColor =  [UIColor colorWithRed:41/255.0 green:79/255.0 blue:115/255.0 alpha:0.7];
        
        for (UIView *view in @[self.profilePicView, self.aboutMeLabel]) {
            [self addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    
    self.profilePicView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 250);
    
    self.aboutMeLabel.frame = CGRectMake(10, CGRectGetMaxY(self.profilePicView.frame) + 60, self.bounds.size.width - 20, 150);
    
    self.updateDescriptionButton.frame = CGRectMake(CGRectGetWidth(self.bounds)/2 - 50, CGRectGetMaxY(self.profilePicView.frame) + 20, 100, 50);
}

#pragma mark - Setter Methods

-(void) setIsCurrentUser:(BOOL)isCurrentUser
{
    _isCurrentUser = isCurrentUser;
    
    if (isCurrentUser) {
        self.updateDescriptionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.updateDescriptionButton setTitle:@"Update Bio" forState:UIControlStateNormal];
        [self.updateDescriptionButton addTarget:self action:@selector(updateBioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.updateDescriptionButton]) {
            [self addSubview:view];
        }
    }
}

-(void) setProfilePic:(UIImage *)profilePic
{
    _profilePic = profilePic;
    
    self.profilePicView.image = profilePic;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
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

@end
