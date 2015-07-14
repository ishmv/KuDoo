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
        [self p_downloadUserPictureMedia];
        
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
            imageView;
        });
        
        for (UIView *view in @[self.profilePicView, self.usernameLabel]) {
            [self.backgroundImageView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        _userInformation = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView .backgroundColor = [UIColor clearColor];
            [tableView registerClass:[LMProfileTableViewCell class] forCellReuseIdentifier:cellIdentifier];
            tableView;
        });
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffect.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [visualEffect.contentView addSubview:vibrancyEffectView];
        
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
        
        CGFloat backgroundImageHeight = CGRectGetHeight(self.view.frame)/2.0;
        
        self.exitButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 52, backgroundImageHeight/2.0 - 82, 44, 44);
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
    
    CGFloat backgroundImageHeight = viewHeight/2.0;
    
    CONSTRAIN_HEIGHT(_backgroundImageView, backgroundImageHeight);
    CONSTRAIN_WIDTH(_backgroundImageView, viewWidth);
    ALIGN_VIEW_TOP(self.view, _backgroundImageView);
    ALIGN_VIEW_LEFT(self.view, _backgroundImageView);
    
    CONSTRAIN_WIDTH(_profilePicView, 125);
    CONSTRAIN_HEIGHT(_profilePicView, 125);
    CENTER_VIEW(_backgroundImageView, _profilePicView);
    
    CENTER_VIEW_H(_backgroundImageView, _usernameLabel);
    ALIGN_VIEW_TOP_CONSTANT(_backgroundImageView, _usernameLabel, 34);
    
    CONSTRAIN_WIDTH(_userInformation, viewWidth);
    CONSTRAIN_HEIGHT(_userInformation, backgroundImageHeight);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _userInformation, backgroundImageHeight + 5);
    
    self.tableBackgroundView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
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
            cell.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 4:
        {
            cell.cellImageView.image = self.profilePicView.image;
            [cell.cellImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [cell.cellImageView.layer setBorderWidth:1.5f];
            
            self.bioTextView = ({
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 100, 100)];
                textView.editable = NO;
                textView.scrollEnabled = YES;
                textView.selectable = YES;
                textView.contentInset = UIEdgeInsetsMake(-12.0f, -5.0f, 0, 0);
                textView.backgroundColor = [UIColor clearColor];
                textView.textColor = [UIColor whiteColor];
                textView.font = [UIFont lm_robotoLightMessage];
                textView.text = self.viewModel.bioString;
                textView;
            });
            
            cell.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 100, 150);
            [cell.titleLabel addSubview:self.bioTextView];
        }
            break;
        default:
            break;
    }
    
    [cell.cellImageView.layer setMasksToBounds:YES];
    [cell.cellImageView.layer setCornerRadius:20.0f];
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
