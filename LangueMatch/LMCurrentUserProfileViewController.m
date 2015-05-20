#import "LMCurrentUserProfileViewController.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"
#import "AppConstant.h"
#import "LMParseConnection.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"

#import <Parse/Parse.h>

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithSelection)(NSString *language);

@interface LMCurrentUserProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIButton *profilePicCameraButton;
@property (strong, nonatomic) UIButton *backgroundImageCameraButton;

@property (nonatomic, assign) NSInteger pictureType;

@end

@implementation LMCurrentUserProfileViewController

static NSString *cellIdentifier = @"myCell";

-(instancetype)initWith:(PFUser *)user
{
    if (self = [super initWith:[PFUser currentUser]]){
        
        _profilePicCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundImageCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        for (UIButton *button in @[self.profilePicCameraButton, self.backgroundImageCameraButton]) {
            [button setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        for (UIView *view in @[self.backgroundImageCameraButton, self.profilePicCameraButton]) {
            [self.backgroundImageView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.profilePicView setUserInteractionEnabled:YES];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"profile.png"]];
    self.tabBarItem.title = @"Profile";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CONSTRAIN_WIDTH(_profilePicCameraButton, 25);
    CONSTRAIN_HEIGHT(_profilePicCameraButton, 25);
    
    ALIGN_VIEW_LEFT_CONSTANT(self.backgroundImageView, _profilePicCameraButton, 130);
    ALIGN_VIEW_TOP_CONSTANT(self.backgroundImageView, _profilePicCameraButton, 50);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.backgroundImageView, _backgroundImageCameraButton, -5);
    ALIGN_VIEW_RIGHT_CONSTANT(self.backgroundImageView, _backgroundImageCameraButton, -5);
}

#pragma mark - Table View Delegate

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
                [self changeUsernameWithCompletion:^(NSString *username) {
                    NSLog(@"Change Name");
                }];
                break;
            case 1:
                [self changeLanguageType:LMLanguageChoiceTypeFluent withCompletion:^(NSString *language) {
                    NSLog(@"Change Fluent Language");
                }];
                break;
            case 2:
                [self changeLanguageType:LMLanguageChoiceTypeDesired withCompletion:^(NSString *language) {
                    NSLog(@"Change Desired Language");
                }];
                break;
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
    cell.accessoryView = accessoryView;
    cell.userInteractionEnabled = YES;

    return cell;
    
}

#pragma mark - Touch Handling

-(void)cameraButtonPressed:(UIButton *)sender
{
    if (sender == _backgroundImageCameraButton) _pictureType = LMUserPictureBackground;
    else _pictureType = LMUserPictureSelf;
    
    UIAlertController *cameraSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger selection) {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = selection;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraSourceTypeAlert animated:YES completion:nil];
}

-(void) changeLanguageType:(LMLanguageChoiceType)type withCompletion:(LMCompletedWithSelection)completion
{
    UIAlertController *chooseLanguage = [LMAlertControllers chooseLanguageAlertWithCompletionHandler:^(NSInteger language) {
        NSString *languageChoice = [LMGlobalVariables LMLanguageOptions][language];
        completion(languageChoice);
        [LMParseConnection saveUserLanguageSelection:language forType:type];
    }];
    
    [self presentViewController:chooseLanguage animated:YES completion:nil];
}

-(void) changeUsernameWithCompletion:(LMCompletedWithUsername)completion
{
    UIAlertController *changeUsernameAlert = [LMAlertControllers changeUsernameAlertWithCompletion:^(NSString *username) {
        if (username.length != 0)
        {
            //Need to make sure username is not taken
            completion(username);
            [LMParseConnection saveUsersUsername:username];
        }
    }];
    
    [self presentViewController:changeUsernameAlert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    if (_pictureType == LMUserPictureBackground) {
        [LMParseConnection saveUserImage:editedImage forType:LMUserPictureBackground];
        self.backgroundImageView.image = editedImage;
    } else {
        [LMParseConnection saveUserImage:editedImage forType:LMUserPictureSelf];
        self.profilePicView.image = editedImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
