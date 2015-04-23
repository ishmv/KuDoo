#import "LMChatDetailsViewController.h"
#import "LMChatDetailsView.h"
#import "LMAlertControllers.h"
#import "AppConstant.h"

@interface LMChatDetailsViewController () <LMChatDetailsViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (copy, nonatomic) void (^LMCompletedChatDetails)(NSDictionary *chatDetails);
@property (strong, nonatomic) LMChatDetailsView *chatDetailsView;

@end

@implementation LMChatDetailsViewController

-(instancetype)initWithCompletion:(LMCompletedChatDetails)completion
{
    if (self = [super init]) {
        
        if (completion) {
            _LMCompletedChatDetails = completion;
        }
            
        _chatDetailsView = [[LMChatDetailsView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _chatDetailsView.delegate = self;
        [self.view addSubview:_chatDetailsView];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LMChatDetailsView Delegate

-(void)chatImageViewTapped:(UIImageView *)imageView
{
    UIAlertController *cameraTypeAlert = [LMAlertControllers choosePictureSourceAlertWithCompletion:^(NSInteger type) {
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.delegate = self;
        imagePickerVC.sourceType = type;
        [self.navigationController presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    [self presentViewController:cameraTypeAlert animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = info[@"UIImagePickerControllerEditedImage"];
    self.chatDetailsView.chatImageView.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneButtonPressed:(UIButton *)sender
{
    UIImage *chatImage = _chatDetailsView.chatImageView.image;
    NSString *chatTitle = ([_chatDetailsView.chatTitle.text length] > 0) ? _chatDetailsView.chatTitle.text : @"Chat";
    NSDictionary *chatDetailsDictionary = @{PF_CHAT_PICTURE : chatImage, PF_CHAT_TITLE : chatTitle};
    
    self.LMCompletedChatDetails(chatDetailsDictionary);
}

@end
