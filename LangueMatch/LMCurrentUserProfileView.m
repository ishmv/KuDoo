#import "LMCurrentUserProfileView.h"
#import "NSArray+LanguageOptions.h"
#import "AppConstant.h"
#import "ParseConnection.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "LMProfileTableViewCell.h"
#import "Utility.h"
#import "LMAlertControllers.h"
#import "LMLanguagePicker.h"
#import "LMUserViewModel.h"
#import "LMLocationPicker.h"

#import <Parse/Parse.h>

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithSelection)(NSString *language);

@interface LMCurrentUserProfileView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, LMLocationPickerDelegate>

@property (strong, nonatomic) UIButton *profilePicCameraButton;
@property (strong, nonatomic) UIButton *backgroundImageCameraButton;

@property (strong, nonatomic) UITextField *locationSearchField;
@property (nonatomic, assign) NSInteger pictureType;

@property (nonatomic, strong) LMLocationPicker *locationPicker;

@property (strong, nonatomic) UIButton *doneEditingButton;

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
    
    self.doneEditingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor lm_tealColor];
        [button setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_finishedEditingBio:) forControlEvents:UIControlEventTouchUpInside];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.layer setCornerRadius:20.0f];
        [button.layer setMasksToBounds:YES];
        [button setHidden:YES];
        button;
    });

    [self.view addSubview:self.doneEditingButton];
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
    ALIGN_VIEW_TOP_CONSTANT(self.backgroundImageView, _profilePicCameraButton, self.view.frame.size.height/6 - 57.5);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(self.backgroundImageView, _backgroundImageCameraButton, -5);
    ALIGN_VIEW_RIGHT_CONSTANT(self.backgroundImageView, _backgroundImageCameraButton, -5);
    
    CONSTRAIN_WIDTH(_doneEditingButton, 40);
    CONSTRAIN_HEIGHT(_doneEditingButton, 40);
    ALIGN_VIEW_RIGHT_CONSTANT(self.view, _doneEditingButton, -5);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.view, _doneEditingButton, -258);
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
                [self p_addFluentLanguage];
                break;
            case 1:
                [self p_changeDesiredLanguage];
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
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self.bioTextView becomeFirstResponder];
            }
                break;
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
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            break;
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            break;
        case 2:
        {
            NSString *location = [PFUser currentUser][PF_USER_LOCATION];
            
            if ([location isEqualToString:NSLocalizedString(@"Somewhere over there", @"somewhere over there")] || !location) {
                cell.titleLabel.text = NSLocalizedString(@"Tap me...", @"tap to add location");
                cell.titleLabel.textColor = [UIColor lm_silverColor];
            } else {
                cell.titleLabel.text = location;
            }
        }
            
            break;
            
        case 3:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            break;
        case 4:
        {
            if ([self.bioTextView.text isEqualToString:NSLocalizedString(@"Nothing yet", @"nothing yet")] || [cell.titleLabel.text isEqualToString:@""]) {
               self.bioTextView.text = NSLocalizedString(@"Add something about yourself! Tap to start...", @"add bio placeholder");
                self.bioTextView.textColor = [UIColor lm_silverColor];
            }
            self.bioTextView.editable = YES;
            self.bioTextView.delegate = self;
        }
            break;
        default:
            break;
    }
    
    return cell;
    
}

#pragma mark - Touch Handling

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.bioTextView.textColor = [UIColor lm_wetAsphaltColor];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.userInformation.contentOffset = CGPointMake(0, 200);
    } completion:^(BOOL finished) {
        [self.doneEditingButton setHidden:NO];
        [self.view bringSubviewToFront:self.doneEditingButton];
    }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.doneEditingButton setHidden:YES];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.userInformation.contentOffset = CGPointMake(0, 0);
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.bioTextView resignFirstResponder];
}

-(void) p_addFluentLanguage
{
    PFUser *currentUser = [PFUser currentUser];
    
    LMLanguagePicker *languagePicker;
    NSString *nativeLangage = self.user[PF_USER_FLUENT_LANGUAGE];
    NSString *desiredLanguage = self.user[PF_USER_DESIRED_LANGUAGE];
    UIAlertView *languageAlreadySelected = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Languge Selected", @"language selected") message:NSLocalizedString(@"Already a chosen language", @"already a chosen language")  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles: nil];
    
    if (!currentUser[PF_USER_FLUENT_LANGUAGE2]) {
        
        languagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx) {
            NSString *languageSelection = [[NSArray lm_languageOptionsEnglish][idx] lowercaseString];
            
            if (![languageSelection isEqualToString:nativeLangage] && ![languageSelection isEqualToString:desiredLanguage]) {
                [ParseConnection saveUserLanguageSelection:idx forType:LMLanguageSelectionTypeFluent2];
                [self p_fetchUserInformation];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [languageAlreadySelected show];
            }
        }];
        
    } else if (!currentUser[PF_USER_FLUENT_LANGUAGE3]) {
        languagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx) {
            NSString *languageSelection = [[NSArray lm_languageOptionsEnglish][idx] lowercaseString];
            NSString *fluentLanguage2 = currentUser[PF_USER_FLUENT_LANGUAGE2];
            
            if (![languageSelection isEqualToString:nativeLangage] && ![languageSelection isEqualToString:fluentLanguage2] && ![languageSelection isEqualToString:desiredLanguage]) {
                [ParseConnection saveUserLanguageSelection:idx forType:LMLanguageSelectionTypeFluent3];
                [self p_fetchUserInformation];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [languageAlreadySelected show];
            }
        }];
    
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"sorry") message:NSLocalizedString(@"Only three fluent languages supported", @"only three fluent languages supported") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles: nil];
        
        [alert show];
        return;
        
    }
    
    languagePicker.title = NSLocalizedString(@"Language Picker", @"language picker");
    languagePicker.pickerTitle = NSLocalizedString(@"Add a language", @"add a language");
    languagePicker.hidesBottomBarWhenPushed = YES;
    [languagePicker.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:languagePicker animated:YES];
}

-(void) p_changeDesiredLanguage
{
    NSString *nativeLangage = self.user[PF_USER_FLUENT_LANGUAGE];
    NSString *fluentLanguage2 = self.user[PF_USER_FLUENT_LANGUAGE2];
    NSString *fluentLanguage3 = self.user[PF_USER_FLUENT_LANGUAGE3];
    
    LMLanguagePicker *languagePicker = [[LMLanguagePicker alloc] initWithTitles:[NSArray lm_languageOptionsNative] images:[NSArray lm_countryFlagImages] andCompletion:^(NSInteger idx) {
         NSString *languageSelection = [[NSArray lm_languageOptionsEnglish][idx] lowercaseString];
        
        if (idx != 0) {
            if (![languageSelection isEqualToString:nativeLangage] && ![languageSelection isEqualToString:fluentLanguage2] && ![languageSelection isEqualToString:fluentLanguage3]) {
                [ParseConnection saveUserLanguageSelection:idx forType:LMLanguageSelectionTypeDesired];
                [self p_fetchUserInformation];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertView *nativeLanguageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Select different language", @"select different language") message:NSLocalizedString(@"Already a chosen language", @"already a chosen language") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [nativeLanguageAlert show];
            }
        } else {
            UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No language selected", @"no language selected") message:NSLocalizedString(@"Please make a selection", @"please make a selection") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles: nil];
            
            [noSelectionAlert show];
        }
    }];
    
    languagePicker.title = NSLocalizedString(@"Language Picker", @"language picker");
    languagePicker.pickerTitle = NSLocalizedString(@"Select Learning Language", @"select learning language");
    languagePicker.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:languagePicker animated:YES];
}

-(void)cameraButtonPressed:(UIButton *)sender
{
    if (sender == _backgroundImageCameraButton) _pictureType = LMUserPictureBackground;
    else _pictureType = LMUserPictureSelf;
    
    UIAlertController *cameraSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger selection) {
        
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        } 
        
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = selection;
        imagePickerVC.navigationBar.tintColor = [UIColor blackColor];
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraSourceTypeAlert animated:YES completion:nil];
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
        [locationString appendString:[NSString stringWithFormat:@"%@", placemark.locality]];
    }
    
    if (placemark.administrativeArea.length > 0) {
        if (placemark.locality.length > 0) {
            [locationString appendString:[NSString stringWithFormat:@", %@ ", placemark.administrativeArea]];
        } else {
            [locationString appendString:[NSString stringWithFormat:@"%@ ", placemark.administrativeArea]];
        }
    }
    
    if (placemark.country.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@"%@", placemark.country]];
    }
    
    [ParseConnection saveUserLocation:locationString];
    [self p_fetchUserInformation];
}

#pragma mark - Helper Methods

-(void) p_fetchUserInformation
{
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.viewModel reloadData];
        [self.userInformation reloadData];
    }];
}


-(void) p_finishedEditingBio:(UIButton *)sender
{
    if (self.bioTextView.text.length != 0) {
        [ParseConnection saveUserBio:self.bioTextView.text];
    }
    
    [self.bioTextView resignFirstResponder];
}

@end