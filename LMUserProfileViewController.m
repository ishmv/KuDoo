#import "LMUserProfileViewController.h"
#import "LMUsers.h"
#import "LMProfileView.h"
#import "AppConstant.h"

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
    
    __block UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.delegate = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"From Where?", @"From Where?") message:NSLocalizedString(@"Choose location", @"Choose location") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *fromLibrary = [UIAlertAction actionWithTitle:@"From Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    UIAlertAction *takePicture = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    UIAlertAction *fromPhotoAlbum = [UIAlertAction actionWithTitle:@"From Photos Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    for (UIAlertAction *action in @[cancel, fromLibrary, takePicture, fromPhotoAlbum]) {
        [alertController addAction:action];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)didTapUpdateBioButton:(UIButton *)button
{
    NSLog(@"Update Bio button pressed");
    
    //ToDo Push Sign Up View subclass
}

-(void)didTapChatButton:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:self.user];
}


#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Got image!");
    [self saveImage:info[@"UIImagePickerControllerEditedImage"]];
}

-(void)saveImage:(UIImage *)image
{
    [[LMUsers sharedInstance] saveUserProfileImage:image];
    [self downloadUserProfilePicture];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
