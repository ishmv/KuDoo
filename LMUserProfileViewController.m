#import "LMUserProfileViewController.h"
#import "LMUsers.h"
#import "LMProfileView.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"
#import "LMGlobalVariables.h"

#import <Parse/Parse.h>

@interface LMUserProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LMProfileViewDelegate>

@property (nonatomic, strong) LMProfileView *profileView;

@end

@implementation LMUserProfileViewController

-(instancetype) init
{
    if (self = [super init])
    {
        self.profileView = [[LMProfileView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        self.profileView.profileViewDelegate = self;
        [self.view addSubview:self.profileView];
        
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"profile.png"]];
    self.tabBarItem.title = @"Profile";
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_user == [PFUser currentUser]) {
        [self downloadUserProfilePicture];
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(didTapCameraButton:)];
        [self.navigationItem setRightBarButtonItem:cameraButton];
    } else {
        UIBarButtonItem *sendMessageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didTapChatButton:)];
        [self.navigationItem setRightBarButtonItem:sendMessageButton];
    }
}

#pragma mark - Setter Methods

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    self.profileView.user = user;
    [self downloadUserProfilePicture];
}

#pragma mark - Backend Methods

-(void) downloadUserProfilePicture
{
    PFFile *profilePicFile = _user[@"picture"];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.profileView.profilePic = [UIImage imageWithData:data];
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
}

#pragma mark - LMProfileView Delegate

-(void)didTapCameraButton:(UIBarButtonItem *)sender
{
    UIAlertController *cameraSourceTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger selection) {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = selection;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraSourceTypeAlert animated:YES completion:nil];
}

-(void)didTapChatButton:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:self.user];
}

-(void) changeLanguageType:(LMLanguageChoiceType)type withCompletion:(LMCompletedWithSelection)completion
{
    UIAlertController *chooseLanguage = [LMAlertControllers chooseLanguageAlertWithCompletionHandler:^(NSInteger language) {
        NSString *languageChoice = [LMGlobalVariables LMLanguageOptions][language];
        completion(languageChoice);
        [LMUsers saveUserLanguageSelection:language forType:type];
    }];

    [self presentViewController:chooseLanguage animated:YES completion:nil];
}

-(void) changeUsernameWithCompletion:(LMCompletedWithUsername)completion
{
    UIAlertController *changeUsernameAlert = [LMAlertControllers changeUsernameAlertWithCompletion:^(NSString *username) {
        completion(username);
        [LMUsers saveUsersUsername:username];
    }];
    
    [self presentViewController:changeUsernameAlert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self saveImage:info[@"UIImagePickerControllerEditedImage"]];
}

-(void)saveImage:(UIImage *)image
{
    [LMUsers saveUserProfileImage:image];
    [self downloadUserProfilePicture];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
