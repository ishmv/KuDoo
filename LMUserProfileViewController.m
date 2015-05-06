#import "LMUserProfileViewController.h"
#import "AppConstant.h"
#import "LMGlobalVariables.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "LMParseConnection.h"

#import <Parse/Parse.h>

@interface LMUserProfileViewController ()

@property (nonatomic, strong) UITableView *userInformation;
@property (nonatomic, strong) NSMutableArray *userInfoStrings;

@end

@implementation LMUserProfileViewController

static NSString *cellIdentifier = @"myCell";

-(instancetype) initWith:(PFUser *)user
{
    if (self = [super init])
    {
        _user = user;
        [self p_downloadUserProfilePicture];
        
        _profilePicView = [UIImageView new];
        
        _userInformation = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        for (UIView *view in @[self.profilePicView, self.userInformation])
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
    
    [self.userInfoStrings addObject:[self.user[PF_USER_USERNAME] copy]];
    [self.userInfoStrings addObject:[self.user[PF_USER_FLUENT_LANGUAGE] copy]];
    [self.userInfoStrings addObject:[self.user[PF_USER_DESIRED_LANGUAGE] copy]];
    
    self.profilePicView.userInteractionEnabled = NO;
    
    self.userInformation.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userInformation.dataSource = self;
    self.userInformation.delegate = self;
    [self.userInformation registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.userInformation.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0];
    
    self.view.backgroundColor =  [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CONSTRAIN_WIDTH(_profilePicView, 250);
    CONSTRAIN_HEIGHT(_profilePicView, 250);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _profilePicView, 44);
    
    CONSTRAIN_WIDTH(_userInformation, self.view.frame.size.width);
    CONSTRAIN_HEIGHT(_userInformation, self.view.frame.size.height);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, 294);
}

#pragma mark - Private Methods

-(void) p_downloadUserProfilePicture
{
    PFFile *profilePicFile = _user[@"picture"];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *profilePicture = [UIImage imageWithData:data];
                [self.profilePicView setImage:profilePicture];
//                [self addMaskToImageView:_profilePicView];
            });
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
}


#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
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
}

#pragma mark - Helper Method

-(void) addMaskToImageView:(UIImageView *)imageView
{
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds)) radius:CGRectGetHeight(imageView.bounds)/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    imageView.layer.mask = mask;
    imageView.layer.masksToBounds = YES;
}

@end
