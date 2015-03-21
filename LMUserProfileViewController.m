#import "LMUserProfileViewController.h"
#import <Parse/Parse.h>
#import "LMProfileView.h"

@interface LMUserProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LMProfileViewDelegate>

@property (nonatomic, strong) LMProfileView *profileView;

@end

@implementation LMUserProfileViewController

NSString *const LMInitiateChatNotification = @"LMInitiateChatNotification";

-(instancetype) init
{
    if (self = [super init]) {
        self.profileView = [LMProfileView new];
        self.profileView.profileViewDelegate = self;
        [self.view addSubview:self.profileView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.profileView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setUser:(PFUser *)user
{
    _user = user;
    self.profileView.aboutMeText = _user[@"bio"];
    
    if ([PFUser currentUser] == _user) {
        self.profileView.isCurrentUser = YES;
    } else {
        self.profileView.isCurrentUser = NO;
    }
    
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

-(void)didTapProfileImageView:(UIImageView *)view
{
    //Todo Page sheet take picture or choose from library
    NSLog(@"User pressed Button");
    UIImagePickerController *imagePckerVC = [[UIImagePickerController alloc] init];
    imagePckerVC.allowsEditing = YES;
    imagePckerVC.delegate = self;
    [self.navigationController presentViewController:imagePckerVC animated:YES completion:nil];
}

-(void)didTapUpdateBioButton:(UIButton *)button
{
    NSLog(@"Update Bio button pressed");
    
    //ToDo Push Sign Up View subclass
}

-(void)didTapChatButton:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LMInitiateChatNotification object:self.user];
}


#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Got image!");
    [self saveImage:info[@"UIImagePickerControllerEditedImage"]];
}

-(void)saveImage:(UIImage *)image
{
    PFUser *user = [PFUser currentUser];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    PFFile *imageFile = [PFFile fileWithName:@"picture" data:imageData];
    
    //Set Thumbnail
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(70, 70), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 70, 70)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbnailData = UIImageJPEGRepresentation(newImage, 1.0);
    PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail" data:thumbnailData];
    
    user[@"picture"] = imageFile;
    user[@"thumbnail"] = thumbnailFile;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self downloadUserProfilePicture];
        } else {
            NSLog(@"There was an error getting the image");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
