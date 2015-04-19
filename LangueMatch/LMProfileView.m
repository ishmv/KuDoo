#import "LMProfileView.h"
#import "Utility.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>

@interface LMProfileView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, assign) BOOL isCurrentUser;
@property (nonatomic, strong) UITableView *userInformation;
@property (nonatomic, strong) NSMutableArray *userInfoStrings;

@end

@implementation LMProfileView

static NSString *cellIdentifier = @"myCell";

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        _profilePicView = [UIImageView new];
        _profilePicView.userInteractionEnabled = NO;

        _userInformation = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(_profilePicView.frame)) style:UITableViewStyleGrouped];
        _userInformation.separatorStyle = UITableViewCellSeparatorStyleNone;
        _userInformation.dataSource = self;
        _userInformation.delegate = self;
        [_userInformation registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _userInformation.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0];
        
        self.backgroundColor =  [UIColor whiteColor];
        
        for (UIView *view in @[self.profilePicView, self.userInformation]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    CONSTRAIN_WIDTH(_profilePicView, viewWidth);
    CONSTRAIN_HEIGHT(_profilePicView, 200);
}


#pragma mark - Setter Methods

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    self.isCurrentUser = ([user.objectId isEqualToString:[PFUser currentUser].objectId]) ? YES : NO;
    
    if (!_userInfoStrings) {
        self.userInfoStrings = [NSMutableArray array];
    }
    
    [self.userInfoStrings addObject:[user[PF_USER_USERNAME] copy]];
    [self.userInfoStrings addObject:[user[PF_USER_FLUENT_LANGUAGE] copy]];
    [self.userInfoStrings addObject:[user[PF_USER_DESIRED_LANGUAGE] copy]];
}

-(void) setProfilePic:(UIImage *)profilePic
{
    _profilePic = profilePic;
    
    self.profilePicView.image = profilePic;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    [self addMaskToImageView:_profilePicView];
}


#pragma mark - Table View Data Source and Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.isCurrentUser) {
    
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
        cell.accessoryView = accessoryView;
        cell.userInteractionEnabled = YES;
        
    } else {

        cell.textLabel.textColor = [UIColor whiteColor];
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    cell.imageView.frame = CGRectMake(0, 0, 35, 35);
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont lm_applicationFontLarge];
    cell.textLabel.text = _userInfoStrings[indexPath.section];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 20)];
    headerLabel.font = [UIFont lm_applicationFontSmall];
    headerLabel.textColor = [UIColor colorWithRed:243/255.0 green:156/255.0 blue:18/255.0 alpha:1.0];
    
    if (section == 0) {
        headerLabel.text = @"  USERNAME";
    } else if (section == 1) {
        headerLabel.text = @"  FLUENT LANGUAGE";
    } else if (section == 2) {
        headerLabel.text = @"  LEARNING LANGUAGE";
    }
    
    return headerLabel;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *accessoryView = cell.accessoryView;
    
    accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
    
    [UIView animateWithDuration:1.0 animations:^{
        accessoryView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        switch (indexPath.section) {
            case 0:
                [self changeUsernameButtonPressedInCell:cell];
                break;
            case 1:
                [self changeLanguageButtonPressedInCell:cell withType:LMLanguageChoiceTypeFluent];
                break;
            case 2:
                [self changeLanguageButtonPressedInCell:cell withType:LMLanguageChoiceTypeDesired];
                break;
        }
    }];
}

#pragma mark - Delegate Methods


-(void)startChatButtonPressed:(UIButton *)sender
{
    [self.profileViewDelegate didTapChatButton:sender];
}

-(void) changeUsernameButtonPressedInCell:(UITableViewCell *)cell
{
    [self.profileViewDelegate changeUsernameWithCompletion:^(NSString *username) {
        cell.textLabel.text = username;
    }];
}


-(void) changeLanguageButtonPressedInCell:(UITableViewCell *)cell withType:(LMLanguageChoiceType)type
{
    [self.profileViewDelegate changeLanguageType:type withCompletion:^(NSString *language) {
        cell.textLabel.text = language;
    }];
}


#pragma mark - Helper Method

-(void) addMaskToImageView:(UIImageView *)imageView
{
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds)) radius:CGRectGetHeight(imageView.bounds)/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    imageView.layer.mask = mask;
}


@end
