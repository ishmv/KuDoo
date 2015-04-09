#import "LMUserProfileViewController.h"
#import "LMUsers.h"
#import "LMProfileView.h"

#import <Parse/Parse.h>


@interface LMUserProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LMProfileViewDelegate>

@property (nonatomic, strong) LMProfileView *profileView;

@end

@implementation LMUserProfileViewController

NSString *const LMInitiateChatNotification = @"LMInitiateChatNotification";

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
    
    [self.tabBarItem setImage:[UIImage imageNamed:@"sample-1040-checkmark.png"]];
    self.tabBarItem.title = @"Profile";
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [[LMUsers sharedInstance] saveUserProfileImage:image];
    [self downloadUserProfilePicture];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
