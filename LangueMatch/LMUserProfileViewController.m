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
        [self p_downloadUserPictureMedia];
        
        _viewModel = [[LMUserViewModel alloc] initWithUser:_user];
        
        _profilePicView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [[imageView layer] setBorderColor:[UIColor whiteColor].CGColor];
            [[imageView layer] setBorderWidth:2.0f];
            [[imageView layer] setMasksToBounds:YES];
            imageView;
        });
        
        _usernameLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont lm_robotoRegularTitle];
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
        
        _lineLabel = [UILabel new];
        _lineLabel.backgroundColor = [UIColor whiteColor];
        
        for (UIView *view in @[self.profilePicView, self.usernameLabel, self.lineLabel]) {
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
        
        for (UIView *view in @[self.backgroundImageView, self.userInformation]) {
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
        self.exitButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(exitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(8, 25, 40, 40);
            button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            [button.layer setCornerRadius:20.0f];
            button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
            [button.layer setMasksToBounds:YES];
            button;
        });

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
    
    CGFloat backgroundImageHeight = (viewHeight/3.0) + 10;
    
    CONSTRAIN_HEIGHT(_backgroundImageView, backgroundImageHeight);
    CONSTRAIN_WIDTH(_backgroundImageView, viewWidth);
    ALIGN_VIEW_TOP(self.view, _backgroundImageView);
    ALIGN_VIEW_LEFT(self.view, _backgroundImageView);
    
    CONSTRAIN_WIDTH(_profilePicView, 115);
    CONSTRAIN_HEIGHT(_profilePicView, 115);
    CENTER_VIEW(_backgroundImageView, _profilePicView);
    
    CENTER_VIEW_H(_backgroundImageView, _usernameLabel);
    ALIGN_VIEW_BOTTOM_CONSTANT(_backgroundImageView, _usernameLabel, -15);
    
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
            [cell.cellImageView.layer setBorderWidth:1.5f];
            [cell.cellImageView.layer setMasksToBounds:YES];
            
            self.bioTextView = ({
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 100, 100)];
                textView.editable = NO;
                textView.scrollEnabled = YES;
                textView.selectable = YES;
                textView.contentInset = UIEdgeInsetsMake(-12.0f, 0, 0, 0);
                textView.backgroundColor = [UIColor lm_beigeColor];
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
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePicView.image = [UIImage imageNamed:@"emptyProfile"];
        });
    }
    
    if (userBackgroundFile != nil) {
        [userBackgroundFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    self.backgroundImageView.image = image;
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundImageView.image = [UIImage imageNamed:@"miamiBeach"];
        });
    }
}

@end
