#import "LMCurrentUserProfileView.h"
#import "LMAlertControllers.h"
#import "NSArray+LanguageOptions.h"
#import "AppConstant.h"
#import "ParseConnection.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "LMProfileTableViewCell.h"
#import "Utility.h"
#import "LMUserViewModel.h"
#import "LMLocationPicker.h"

#import <Parse/Parse.h>

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithSelection)(NSString *language);

@interface LMCurrentUserProfileView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, LMLocationPickerDelegate>

@property (strong, nonatomic) UIButton *profilePicCameraButton;
@property (strong, nonatomic) UIButton *backgroundImageCameraButton;

@property (strong, nonatomic) UITextField *locationSearchField;
@property (strong, nonatomic) UITextView *bioView;

@property (nonatomic, assign) NSInteger pictureType;

@property (nonatomic, strong) LMLocationPicker *locationPicker;

@end

@implementation LMCurrentUserProfileView

static NSString *cellIdentifier = @"myCell";

-(instancetype)initWithUser:(PFUser *)user
{
    if (self = [super initWithUser:[PFUser currentUser]]){
        
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

// For Segue instantiation in storyboard

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithUser:[PFUser currentUser]];
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
    
    ALIGN_VIEW_LEFT_CONSTANT(self.backgroundImageView, _profilePicCameraButton, self.view.frame.size.width/2 - 62.5);
    ALIGN_VIEW_TOP_CONSTANT(self.backgroundImageView, _profilePicCameraButton, self.view.frame.size.height/6 - 62.5);
    
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
                }];
                break;
            case 1:
                [self changeLanguageType:LMLanguageSelectionTypeFluent1 withCompletion:^(NSString *language) {
                }];
                break;
            case 2:
            {
                if (!_locationPicker) {
                    self.locationPicker = [[LMLocationPicker alloc] init];
                    self.locationPicker.delegate = self;
                }
                
                [self.navigationController pushViewController:self.locationPicker animated:YES];
                
            }
                break;
            case 4:
            default:
                break;
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMProfileTableViewCell *cell = (LMProfileTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.accessoryLabel.text = NSLocalizedString(@"Add", @"Add");
            cell.userInteractionEnabled = YES;
            break;
        case 1:
            cell.accessoryLabel.text = NSLocalizedString(@"Change", @"Change");
            cell.userInteractionEnabled = YES;
            break;
        case 2:
            
            if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Everywhere yet nowhere", @"Everywhere yet nowhere")]) {
                cell.titleLabel.text = NSLocalizedString(@"Add your country, zip code or city", @"Add Location Placeholder");
                cell.titleLabel.textColor = [UIColor lm_silverColor];
            } 
            
            break;
            
        case 3:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            break;
        case 4:
        {
            if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Hmmm.. They are a mystery!", @"Hmm.. They are a mystery!")]) {
               cell.titleLabel.text = NSLocalizedString(@"Add something about yourself for good conversation starters! Also, try writing in your learning language. Tap to start...", @"Add Bio Placeholder");
                cell.titleLabel.textColor = [UIColor lm_silverColor];
                
            }
            
            [cell.contentView addSubview:self.bioView];
        }
        default:
            break;
    }
    
    return cell;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view != self.bioView) [self.bioView resignFirstResponder];
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

-(void) changeLanguageType:(LMLanguageSelectionType)type withCompletion:(LMCompletedWithSelection)completion
{
    UIAlertController *chooseLanguage = [LMAlertControllers chooseLanguageAlertWithCompletionHandler:^(NSInteger language) {
        NSString *languageChoice = [NSArray lm_languageOptionsFull][language];
        completion(languageChoice);
        [ParseConnection saveUserLanguageSelection:language forType:type];
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
            [ParseConnection saveUsersUsername:username];
        }
    }];
    
    [self presentViewController:changeUsernameAlert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    if (_pictureType == LMUserPictureBackground) {
        [ParseConnection saveUserImage:editedImage forType:LMUserPictureBackground];
        self.backgroundImageView.image = editedImage;
    } else {
        [ParseConnection saveUserImage:editedImage forType:LMUserPictureSelf];
        self.profilePicView.image = editedImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LMLocationPicker
-(void)locationPicker:(LMLocationPicker *)locationPicker didSelectLocation:(CLPlacemark *)placemark
{
    NSMutableString *locationString = [[NSMutableString alloc] init];
    
    if (placemark.locality.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@"%@ ", placemark.locality]];
    }
    
    if (placemark.administrativeArea.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@"%@ ", placemark.administrativeArea]];
    }
    
    if (placemark.country.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@"%@", placemark.country]];
    }
    
    LMProfileTableViewCell *cell = (LMProfileTableViewCell *)[self.userInformation cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cell.titleLabel.text = locationString;
    [self.userInformation reloadData];
    [ParseConnection saveUserLocation:locationString];
}

@end