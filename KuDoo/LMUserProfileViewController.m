#import "LMUserProfileViewController.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "UIButton+TapAnimation.h"
#import "NSString+Chats.h"
#import "LMTableViewCell.h"
#import "LMUserViewModel.h"
#import "AppConstant.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface LMUserProfileViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UIButton *exitButton;

@end

@implementation LMUserProfileViewController

static NSString *const cellIdentifier = @"cellIdentifier";

-(instancetype) initWithUser:(PFUser *)user
{
    if (self = [super init])
    {
        _user = user;
        [self p_downloadUserPictureMedia];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffect.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [visualEffect.contentView addSubview:vibrancyEffectView];
        
        _viewModel = [[LMUserViewModel alloc] initWithUser:_user];
        
        _profilePicView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [[imageView layer] setBorderColor:[UIColor whiteColor].CGColor];
            [[imageView layer] setBorderWidth:2.0f];
            [[imageView layer] setMasksToBounds:YES];
            [[imageView layer] setCornerRadius:62.5f];
            imageView;
        });
        
        _usernameLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont lm_robotoRegularLarge];
            label.textColor = [UIColor whiteColor];
            label.text = _user[PF_USER_DISPLAYNAME];
            [label sizeToFit];
            label;
        });
        
        _backgroundImageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.frame = CGRectZero;
            imageView.userInteractionEnabled = YES;
            imageView;
        });
        
        for (UIView *view in @[_profilePicView, _usernameLabel]) {
            [self.backgroundImageView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        _userInformation = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.showsVerticalScrollIndicator = NO;
            tableView .backgroundColor = [UIColor clearColor];
            [tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:cellIdentifier];
            tableView;
        });
        
        _bioTextView = ({
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 65.0f, 150)];
            textView.editable = NO;
            textView.scrollEnabled = YES;
            textView.selectable = YES;
            textView.contentInset = UIEdgeInsetsMake(0.0f, -5.0f, 0, 0);
            textView.backgroundColor = [UIColor clearColor];
            textView.textColor = [UIColor whiteColor];
            textView.font = [UIFont lm_robotoLightMessage];
            textView.text = self.viewModel.bioString;
            textView;
        });
        
        _tableBackgroundView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView;
        });
        
        for (UIView *view in @[_tableBackgroundView, visualEffect, _backgroundImageView, _userInformation]) {
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
    self.view.backgroundColor = [UIColor clearColor];
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
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    
    self.hidesBottomBarWhenPushed = NO;
    
    if (self.isBeingPresented) {
        
        self.exitButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 52, 24.0f, 44.0f, 44.0f);
            button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            [button.layer setCornerRadius:22.0f];
            button.backgroundColor = [[UIColor lm_tealColor] colorWithAlphaComponent:0.7f];
            [button.layer setMasksToBounds:YES];
            button;
        });
        [self.view addSubview:self.exitButton];
        
        self.hidesBottomBarWhenPushed = YES;
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
    CGFloat tableViewOffset = 20.0f;
    CGFloat usernameLabelOffset = 24.0f;
    CGFloat profilePictureHeight = 125.0f;
    
    CGFloat backgroundImageHeight = viewHeight/2.0 - tableViewOffset;
    
    CONSTRAIN_HEIGHT(_backgroundImageView, backgroundImageHeight);
    CONSTRAIN_WIDTH(_backgroundImageView, viewWidth);
    ALIGN_VIEW_TOP(self.view, _backgroundImageView);
    ALIGN_VIEW_LEFT(self.view, _backgroundImageView);
    
    CONSTRAIN_WIDTH(_profilePicView, profilePictureHeight);
    CONSTRAIN_HEIGHT(_profilePicView, profilePictureHeight);
    CENTER_VIEW(_backgroundImageView, _profilePicView);
    
    CENTER_VIEW_H(_backgroundImageView, _usernameLabel);
    ALIGN_VIEW_TOP_CONSTANT(_backgroundImageView, _usernameLabel, usernameLabelOffset);
    
    CONSTRAIN_WIDTH(_userInformation, viewWidth);
    CONSTRAIN_HEIGHT(_userInformation, backgroundImageHeight + tableViewOffset);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, backgroundImageHeight + 5.0f);
    
    self.tableBackgroundView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
}

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.minimumEdgeSpacing = 12.0f;
    cell.titleOffset = 12.0f;
    
    switch (indexPath.section) {
        case 0:
            cell.cellImageView.image = self.viewModel.fluentImage;
            cell.titleLabel.text = self.viewModel.fluentLanguageString;
            cell.titleLabel.numberOfLines = 0;
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
            cell.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 4:
        {
            cell.cellImageView.image = self.profilePicView.image;
            cell.cellImageViewPadding = 105.0f;
            cell.titleOffset = -48.0f;
            cell.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40.0f, 150.0f);
            [cell.titleLabel addSubview:self.bioTextView];
        }
            break;
        default:
            break;
    }
    
    cell.titleLabel.font = [UIFont lm_robotoLightMessage];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return 150;
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
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3;
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

-(void) p_downloadUserPictureMedia
{
    PFFile *userThumbnailFile = _user[PF_USER_THUMBNAIL];
    PFFile *userBackgroundFile = _user[PF_USER_BACKGROUND_PICTURE];
    
    if (userThumbnailFile != nil) {
        [userThumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    self.profilePicView.image = image;
                    [self.userInformation reloadData];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePicView.image = [UIImage imageNamed:@"emptyProfile"];
            [self.userInformation reloadData];
        });
    }
    
    if (userBackgroundFile != nil) {
        [userBackgroundFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    self.backgroundImageView.image = image;
                    self.tableBackgroundView.image = image;
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundImageView.image = [UIImage imageNamed:@"miamiBeach"];
            self.tableBackgroundView.image = [UIImage imageNamed:@"country"];
        });
    }
}

@end
