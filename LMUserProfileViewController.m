#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "LMGlobalVariables.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "LMParseConnection.h"
#import "LMTableViewCell.h"

#import <Parse/Parse.h>

@interface LMUserProfileViewController ()

@property (nonatomic, strong) UITableView *userInformation;
@property (nonatomic, strong) CALayer *backgroundLayer;

@property (nonatomic, strong) NSMutableArray *userInfoStrings;

@property (nonatomic, strong) NSArray *colors;

@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *lineLabel;

@end

@implementation LMUserProfileViewController

static NSString *cellIdentifier = @"reuseIdentifier";

-(instancetype) initWith:(PFUser *)user
{
    if (self = [super init])
    {
        _user = user;
        [self p_downloadUserInformation];

        _profilePicView = [UIImageView new];
        [[_profilePicView layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_profilePicView layer] setBorderWidth:3.0f];
        [[_profilePicView layer] setCornerRadius:31.25f];
        [[_profilePicView layer] setMasksToBounds:YES];
        
        _usernameLabel = [UILabel new];
        _usernameLabel.font = [UIFont lm_noteWorthyLarge];
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameLabel.text = _user[PF_USER_USERNAME];
        [_usernameLabel sizeToFit];
        
        _backgroundImageView = [UIImageView new];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImageView.frame = CGRectMake(0, 0, 100, 100);
        
        _lineLabel = [UILabel new];
        _lineLabel.backgroundColor = [UIColor whiteColor];
        
        for (UIView *view in @[self.profilePicView, self.usernameLabel, self.lineLabel]) {
            [self.backgroundImageView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        _userInformation = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        for (UIView *view in @[self.backgroundImageView, self.userInformation])
        {
            [self.view addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_userInfoStrings) {
        self.userInfoStrings = [NSMutableArray array];
    }
    
    self.colors = @[[UIColor lm_silverColor], [UIColor lm_orangeColor], [UIColor lm_wisteriaColor], [UIColor lm_peterRiverColor], [UIColor lm_lightYellowColor]];
    
    [self.userInfoStrings addObject:[self.user[PF_USER_FLUENT_LANGUAGE] uppercaseString]];
    [self.userInfoStrings addObject:[self.user[PF_USER_DESIRED_LANGUAGE] uppercaseString]];
    [self.userInfoStrings addObject:[self.user[PF_USER_LOCATION] uppercaseString]];
    
    NSDate *userStartDate = self.user.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *userStartDateString = [formatter stringFromDate:userStartDate];
    [self.userInfoStrings addObject:userStartDateString];
    
    
    
    self.profilePicView.userInteractionEnabled = NO;
    
    self.userInformation.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userInformation.dataSource = self;
    self.userInformation.delegate = self;
    self.userInformation.backgroundColor = [UIColor clearColor];
    [self.userInformation registerClass:[LMTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.view.backgroundColor = [UIColor lm_wetAsphaltColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGFloat backgroundImageHeight = viewHeight/3.0;
    
    CONSTRAIN_HEIGHT(_backgroundImageView, backgroundImageHeight);
    CONSTRAIN_WIDTH(_backgroundImageView, viewWidth);
    
    CONSTRAIN_WIDTH(_profilePicView, 115);
    CONSTRAIN_HEIGHT(_profilePicView, 115);
    CENTER_VIEW(_backgroundImageView, _profilePicView);
    
    CENTER_VIEW_H(_backgroundImageView, _usernameLabel);
    ALIGN_VIEW_BOTTOM_CONSTANT(_backgroundImageView, _usernameLabel, -10);
    
    ALIGN_VIEW_BOTTOM(_backgroundImageView, _lineLabel);
    CENTER_VIEW_H(_backgroundImageView, _lineLabel);
    CONSTRAIN_HEIGHT(_lineLabel, 2);
    CONSTRAIN_WIDTH(_lineLabel, viewWidth);
    
    CONSTRAIN_WIDTH(_userInformation, viewWidth);
    CONSTRAIN_HEIGHT(_userInformation, viewHeight - backgroundImageHeight - self.tabBarController.tabBar.frame.size.height);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, backgroundImageHeight + 10);
    
    self.backgroundLayer.frame = self.view.frame;
}

#pragma mark - Private Methods

-(void) p_downloadUserInformation
{
    PFFile *profilePicFile = _user[PF_USER_PICTURE];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *profilePicture = [UIImage imageWithData:data];
                [self.profilePicView setImage:profilePicture];
            });
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
    
    if (_user[PF_USER_BACKGROUND_PICTURE])
    {
        PFFile *profileBackgroundFile = _user[PF_USER_BACKGROUND_PICTURE];
        [profileBackgroundFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *backgroundPicture = [UIImage imageWithData:data];
                    [self.backgroundImageView setImage:backgroundPicture];
                });
            } else {
                NSLog(@"There was an error retrieving profile picture");
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundImageView.image = [UIImage imageNamed:@"miamiBeach.jpg"];
        });
    }
}


#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.cellImageView.layer setCornerRadius:0.0f];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_userInfoStrings.count > indexPath.section) {
        cell.titleLabel.text = _userInfoStrings[indexPath.section];
    }
    
    cell.titleLabel.font = [UIFont lm_noteWorthyMedium];
    
    UIImage *cellImage;
    
    switch (indexPath.section) {
        case 0:
        {
            cellImage = [UIImage imageNamed:@"diploma.png"];
            NSMutableString *detailText = [NSMutableString stringWithString:@"Also fluent in: "];
            
            if (self.user[PF_USER_FLUENT_LANGUAGE2]) [detailText appendString:self.user[PF_USER_FLUENT_LANGUAGE2]];
            if (self.user[PF_USER_FLUENT_LANGUAGE3]) [detailText appendString:self.user[PF_USER_FLUENT_LANGUAGE3]];
            if (self.user[PF_USER_FLUENT_LANGUAGE4]) [detailText appendString:self.user[PF_USER_FLUENT_LANGUAGE4]];
            
            cell.detailLabel.text = detailText;
            break;
        }
        case 1:
            cellImage = [UIImage imageNamed:@"carrot.png"];
            break;
        case 2:
        {
            cellImage = [UIImage imageNamed:@"location.png"];
            
            NSArray *separatedString = [_userInfoStrings[indexPath.section] componentsSeparatedByString:@"/"];
            cell.titleLabel.text = separatedString[0];
            cell.detailLabel.text = separatedString[1];
            break;
        }
        case 3:
            cellImage = [UIImage imageNamed:@"watch.png"];
            break;
        case 4:
            cell.titleLabel.text = @"No Monies";
            cellImage = [UIImage imageNamed:@"money.png"];
            break;
        default:
            break;
    }
    
    cell.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.cellImageView.image = cellImage;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, CGRectGetWidth(self.view.frame) - 130, 30)];
    headerLabel.font = [UIFont lm_noteWorthySmall];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel.layer setCornerRadius:5.0f];
    [headerLabel.layer setMasksToBounds:YES];
    
    
    headerLabel.backgroundColor = self.colors[section];
    
    switch (section) {
        case 0:
            headerLabel.text = @"NATIVE LANGUAGE";
            break;
        case 1:
            headerLabel.text = @"LEARNING";
            break;
        case 2:
            headerLabel.text = @"LOCATION";
            break;
        case 3:
            headerLabel.text = @"MEMBER SINCE";
            break;
        case 4:
            headerLabel.text = @"LangMatch POINTS";
            break;
        default:
            break;
    }
    
    [headerView addSubview:headerLabel];
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0f;
}

@end
