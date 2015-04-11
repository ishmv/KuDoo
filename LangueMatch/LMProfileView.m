#import "LMProfileView.h"
#import "Utility.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>

@interface LMProfileView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *fluentLanguages;
@property (nonatomic, strong) UILabel *desiredLanguage;
@property (nonatomic, strong) UIButton *startChatButton;
@property (nonatomic, strong) UIButton *changeDesiredLanuageButton;
@property (nonatomic, strong) UIView *bottomHalfColor;

@property (nonatomic, strong) UITableView *userInformation;
@property (nonatomic, strong) NSMutableArray *userInfoStrings;

@end

@implementation LMProfileView

static NSString *const cellIdentifier = @"myCell";

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        _profilePicView = [UIImageView new];
        _profilePicView.userInteractionEnabled = NO;

        _fluentLanguages = [UILabel new];
        _fluentLanguages.textAlignment = NSTextAlignmentLeft;
        _fluentLanguages.textColor = [UIColor whiteColor];
        _fluentLanguages.font = [UIFont applicationFontLarge];
        
        [[_fluentLanguages layer] setCornerRadius:15];
        [[_fluentLanguages layer] setBorderWidth:1.0f];
        [[_fluentLanguages layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        
        _desiredLanguage = [UILabel new];
        _desiredLanguage.textAlignment = NSTextAlignmentLeft;
        _desiredLanguage.textColor = [UIColor whiteColor];
        _desiredLanguage.font = [UIFont applicationFontLarge];
        [[_desiredLanguage layer] setCornerRadius:15];
        [[_desiredLanguage layer] setBorderWidth:1.0f];
        [[_desiredLanguage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        
        _usernameLabel = [UILabel new];
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameLabel.textAlignment = NSTextAlignmentCenter;
        _usernameLabel.font = [UIFont applicationFontLarge];
        
        _userInformation = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStylePlain];
        _userInformation.dataSource = self;
        _userInformation.delegate = self;
        [_userInformation registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        
        _bottomHalfColor = [UIView new];
        _bottomHalfColor.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0];
        _bottomHalfColor.frame = CGRectMake(0, 200, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-200);
        
        self.backgroundColor =  [UIColor whiteColor];
        
        for (UIView *view in @[self.bottomHalfColor, self.profilePicView, /*self.fluentLanguages, self.desiredLanguage, self.usernameLabel, */self.userInformation]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
//    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_usernameLabel, _profilePicView, _desiredLanguage, _fluentLanguages, _userInformation);
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_profilePicView, _userInformation);
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
//    CONSTRAIN_WIDTH(_desiredLanguage, viewWidth - 20);
//    CENTER_VIEW_H(self, _desiredLanguage);
//    
//    CONSTRAIN_WIDTH(_fluentLanguages, viewWidth - 20);
//    CENTER_VIEW_H(self, _fluentLanguages);
//    
//    CONSTRAIN_WIDTH(_usernameLabel, 275);
//    CENTER_VIEW_H(self, _usernameLabel);
    
    CONSTRAIN_WIDTH(_profilePicView, viewWidth);
    
    CONSTRAIN_WIDTH(_userInformation, viewWidth - 20);
    CENTER_VIEW_H(self, _userInformation);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_profilePicView(==200)]-20-[_userInformation]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_profilePicView(==200)]-15-[_usernameLabel(==50)]-30-[_fluentLanguages(==50)][_desiredLanguage(==50)]"
//                                                                 options:kNilOptions
//                                                                 metrics:nil
//                                                                   views:viewDictionary]];

}

#pragma mark - Setter Methods

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    BOOL isCurrentUser = ([user.objectId isEqualToString:[PFUser currentUser].objectId]) ? YES : NO;
    
    if (!_userInfoStrings) {
        self.userInfoStrings = [NSMutableArray array];
    }
    
    [self.userInfoStrings addObject:[user[PF_USER_USERNAME] copy]];
    [self.userInfoStrings addObject:[user[PF_USER_FLUENT_LANGUAGE] copy]];
    [self.userInfoStrings addObject:[user[PF_USER_DESIRED_LANGUAGE] copy]];
    
    [self.userInformation registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.userInformation reloadData];
    
    if (isCurrentUser) {
        
//        self.changeDesiredLanuageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [[self.changeDesiredLanuageButton layer] setCornerRadius:10];
//        [self.changeDesiredLanuageButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
//        [self.changeDesiredLanuageButton addTarget:self action:@selector(changeLanguageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
////        self.changeDesiredLanuageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
////        self.changeDesiredLanuageButton.titleLabel.font = [UIFont applicationFontLarge];
//        self.changeDesiredLanuageButton.backgroundColor = [UIColor whiteColor];
////        self.changeDesiredLanuageButton.titleLabel.textColor = [UIColor colorWithRed:243/255.0 green:156/255.0 blue:18/255.0 alpha:1.0];
//        self.changeDesiredLanuageButton.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self.desiredLanguage addSubview:self.changeDesiredLanuageButton];
//        
//        CONSTRAIN_WIDTH(_changeDesiredLanuageButton, 40);
//        CONSTRAIN_HEIGHT(_changeDesiredLanuageButton, 40);
//        CENTER_VIEW_V(self.desiredLanguage, _changeDesiredLanuageButton);
//        ALIGN_VIEW_RIGHT(self.desiredLanguage, _changeDesiredLanuageButton);
        
    } else {
        
//        self.startChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [[self.startChatButton layer] setCornerRadius:15];
//        [self.startChatButton setTitle:NSLocalizedString(@"Say Hey", @"Say Hey") forState:UIControlStateNormal];
//        [self.startChatButton addTarget:self action:@selector(startChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        self.startChatButton.titleLabel.font = [UIFont applicationFontLarge];
//        self.startChatButton.backgroundColor = [UIColor whiteColor];
//        self.startChatButton.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self addSubview:self.startChatButton];
//        
//        CONSTRAIN_WIDTH(_startChatButton, 150);
//        CENTER_VIEW_H(self, _startChatButton);
//        ALIGN_VIEW_BOTTOM_CONSTANT(self, _startChatButton, 30);
//        ALIGN_VIEW_TOP_CONSTANT(self, _startChatButton, CGRectGetHeight(self.frame)-200);
    }
//    
//    self.usernameLabel.text = user[PF_USER_USERNAME];
//    self.fluentLanguages.text = [NSString stringWithFormat:@"Fluent in: %@", user[PF_USER_FLUENT_LANGUAGE]];
//    self.desiredLanguage.text = [NSString stringWithFormat:@"Learning: %@", user[PF_USER_DESIRED_LANGUAGE]];

}

-(void) setProfilePic:(UIImage *)profilePic
{
    _profilePic = profilePic;
    
    self.profilePicView.image = profilePic;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    [self addMaskToImageView:_profilePicView];
}

-(void) setProfileViewDelegate:(id<LMProfileViewDelegate>)profileViewDelegate
{
    _profileViewDelegate = profileViewDelegate;
}

#pragma mark - Delegate Methods


-(void)changeLanguageButtonPressed:(UIButton *)sender
{   
//    [self.profileViewDelegate didTapUpdateBioButton:sender];
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

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings.png"]];
    
    cell.textLabel.text = _userInfoStrings[indexPath.row];
    cell.accessoryView = accessoryView;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_userInfoStrings count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"Username";
//    } else if (section == 1) {
//        return @"Fluent Language";
//    } else if (section == 2) {
//        return @"Learning";
//    }
//    
//    return @"";
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 40;
//}

@end
