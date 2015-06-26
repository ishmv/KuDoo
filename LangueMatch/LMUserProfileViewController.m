#import "LMUserProfileViewController.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "NSString+Chats.h"
#import "LMProfileTableViewCell.h"
#import "LMUserViewModel.h"
#import "UIButton+TapAnimation.h"
#import "AppConstant.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface LMUserProfileViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *lineLabel;

@property (strong, nonatomic) UIButton *exitButton;

@property (strong, nonatomic) LMUserViewModel *viewModel;

@end

@implementation LMUserProfileViewController

static NSString *const cellIdentifier = @"reuseIdentifier";

-(instancetype) initWithUser:(PFUser *)user
{
    if (self = [super init])
    {
        _user = user;
        [self p_downloadUserInformation];
        _viewModel = [[LMUserViewModel alloc] initWithUser:_user];
        
        _profilePicView = [UIImageView new];
        _profilePicView.contentMode = UIViewContentModeScaleAspectFill;
        [[_profilePicView layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_profilePicView layer] setBorderWidth:3.0f];
        [[_profilePicView layer] setMasksToBounds:YES];
        
        _usernameLabel = [UILabel new];
        _usernameLabel.font = [UIFont lm_robotoRegularTitle];
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameLabel.text = _user[PF_USER_DISPLAYNAME];
        [_usernameLabel sizeToFit];
        
        _backgroundImageView = [UIImageView new];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImageView.frame = CGRectZero;
        
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
    
    self.profilePicView.userInteractionEnabled = NO;
    
    self.userInformation.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userInformation.dataSource = self;
    self.userInformation.delegate = self;
    self.userInformation.backgroundColor = [UIColor clearColor];
    [self.userInformation registerClass:[LMProfileTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.backgroundImageView = nil;
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
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    
    self.hidesBottomBarWhenPushed = NO;
    
    if (self.isBeingPresented) {
        self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.exitButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.exitButton addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.exitButton.frame = CGRectMake(20, 30, 40, 40);
        self.exitButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [self.exitButton.layer setCornerRadius:20.0f];
        self.exitButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
        [self.exitButton.layer setMasksToBounds:YES];
        [self.view addSubview:self.exitButton];
    }
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
    ALIGN_VIEW_TOP(self.view, _backgroundImageView);
    ALIGN_VIEW_LEFT(self.view, _backgroundImageView);
    
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
    CONSTRAIN_HEIGHT(_userInformation, viewHeight - backgroundImageHeight - 70);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, backgroundImageHeight + 10);
}

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.imageWidth = 40;
    
    switch (indexPath.section) {
        case 0:
            cell.cellImageView.image = self.viewModel.fluentImage;
            cell.titleLabel.text = self.viewModel.fluentLanguageString;
            break;
        case 1:
            cell.cellImageView.image = self.viewModel.desiredImage;
            cell.titleLabel.text = self.viewModel.desiredLanguageString;
            break;
        case 2:
            cell.cellImageView.image = [UIImage imageNamed:@"location"];
            cell.titleLabel.text = self.viewModel.locationString;
            break;
        case 3:
            cell.cellImageView.image = [UIImage imageNamed:@"watch"];
            cell.titleLabel.text = self.viewModel.memberSinceString;
            break;
        case 4:
        {
            cell.cellImageView.image = self.profilePicView.image;
            [cell.cellImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [cell.cellImageView.layer setBorderWidth:2.0f];
            [cell.cellImageView.layer setMasksToBounds:YES];
            
            self.bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 100, 100)];
            cell.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 100, 100);
            [cell.titleLabel addSubview:self.bioTextView];
            self.bioTextView.editable = NO;
            self.bioTextView.scrollEnabled = YES;
            self.bioTextView.selectable = YES;
            self.bioTextView.contentInset = UIEdgeInsetsMake(-10.0f, 0, 0, 0);
            self.bioTextView.backgroundColor = [UIColor lm_beigeColor];
            self.bioTextView.font = [UIFont lm_robotoLightMessage];
            self.bioTextView.text = self.viewModel.bioString;
        }
            break;
        default:
            break;
    }
    
    cell.textLabel.font = [UIFont lm_robotoLightMessage];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return 100;
    }
    return 45;
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
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Touch Handling

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) exitButtonTapped:(UIButton *)sender
{
    [UIButton lm_animateButtonPush:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

-(void) p_downloadUserInformation
{
    NSArray *userInfo = @[_user[PF_USER_THUMBNAIL], _user[PF_USER_BACKGROUND_PICTURE]];
    
    for (int i = 0; i < userInfo.count; i++) {
        PFFile *imageFile = userInfo[i];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    if (i == 0) self.profilePicView.image = image;
                    if (i == 1) self.backgroundImageView.image = image;
                    [self.userInformation reloadData];
                });
            } else {
                NSLog(@"There was an error retrieving profile picture");
            }
        }];
    }
}

@end
