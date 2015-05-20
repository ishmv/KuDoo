#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "LMGlobalVariables.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "LMParseConnection.h"

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

static NSString *cellIdentifier = @"myCell";

-(instancetype) initWith:(PFUser *)user
{
    if (self = [super init])
    {
        _user = user;
        [self p_downloadUserPictures];

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
    
    self.colors = @[[UIColor lm_orangeColor], [UIColor lm_blueGreenColor], [UIColor lm_alizarinColor]];
    
    [self.userInfoStrings addObject:[self.user[PF_USER_FLUENT_LANGUAGE] uppercaseString]];
    [self.userInfoStrings addObject:[self.user[PF_USER_DESIRED_LANGUAGE] uppercaseString]];
    
    NSDate *userStartDate = self.user.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *userStartDateString = [formatter stringFromDate:userStartDate];
    [self.userInfoStrings addObject:userStartDateString];
    
    self.profilePicView.userInteractionEnabled = NO;
    
    self.userInformation.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userInformation.dataSource = self;
    self.userInformation.delegate = self;
    [self.userInformation registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.backgroundLayer = [LMGlobalVariables universalBackgroundColor];
    self.userInformation.backgroundColor = [UIColor clearColor];
    [self.view.layer insertSublayer:self.backgroundLayer atIndex:0];
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
    CONSTRAIN_HEIGHT(_userInformation, viewHeight - backgroundImageHeight);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, backgroundImageHeight + 10);
    
    self.backgroundLayer.frame = self.view.frame;
}

#pragma mark - Private Methods

-(void) p_downloadUserPictures
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.imageView.frame = CGRectMake(-15, 0, 30, 30);

    CALayer *colorLayer = [CALayer layer];
    colorLayer.backgroundColor = [self.colors[indexPath.section] CGColor];
    [colorLayer setCornerRadius:5.0f];
    [colorLayer setMasksToBounds:YES];
    colorLayer.frame = CGRectMake(30, 0, CGRectGetWidth(self.userInformation.frame) - 60, 70);
    
    [cell.contentView.layer insertSublayer:colorLayer atIndex:0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont lm_noteWorthyLarge];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = _userInfoStrings[indexPath.section];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
    headerLabel.font = [UIFont lm_noteWorthyMedium];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor lm_wetAsphaltColor];
    
    switch (section) {
        case 0:
            headerLabel.text = @"FLUENT LANGUAGES";
            break;
        case 1:
            headerLabel.text = @"LEARNING LANGUAGE";
            break;
        case 2:
            headerLabel.text = @"MEMBER SINCE";
            break;
        default:
            break;
    }
    
    return headerLabel;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
