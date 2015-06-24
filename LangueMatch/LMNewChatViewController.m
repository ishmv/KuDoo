//
//  LMNewChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/23/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMNewChatViewController.h"
#import "Utility.h"
#import "UITextField+LMTextFields.h"
#import "LMPeoplePicker.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "AppConstant.h"
#import "LMAlertControllers.h"

#import <Parse/PFUser.h>

@interface LMNewChatViewController () <UITextFieldDelegate, LMPeoplePickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITextField *chatTitle;
@property (nonatomic, strong) UIImageView *chatImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@property (nonatomic, strong) NSOrderedSet *contacts;

@end

@implementation LMNewChatViewController

static NSInteger const MAX_CHAT_TITLE_LENGTH = 20;

-(instancetype) initWithContacts:(NSOrderedSet *)contacts
{
    if (self = [super init]) {
        _contacts = contacts;
        
        _chatTitle = [UITextField lm_defaultTextFieldWithPlaceholder:NSLocalizedString(@"Chat Title", @"Chat Title")];
        _chatTitle.delegate = self;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        
        _chatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connected"]];
        _chatImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_noteWorthyLargeBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Chat Details", @"Chat Details")];
    [self.navigationItem setTitleView:titleLabel];
    
    self.chatTitle.textColor = [UIColor lm_orangeColor];
    self.chatTitle.backgroundColor = [UIColor whiteColor];
    
    [self.chatImageView.layer setBorderColor:[[UIColor whiteColor] colorWithAlphaComponent:0.85f].CGColor];
    [self.chatImageView.layer setBorderWidth:3.0f];
    [self.chatImageView.layer setMasksToBounds:YES];
    
    self.chatImageView.userInteractionEnabled = YES;
    [self.chatImageView addGestureRecognizer:self.tapGesture];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    [self.nextButton setEnabled:NO];
    
    for (UIView *view in @[self.chatTitle, self.chatImageView]) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat topBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame) + 20;
    
    CONSTRAIN_HEIGHT(_chatTitle, 50);
    CONSTRAIN_WIDTH(_chatTitle, 250);
    CENTER_VIEW_H(self.view, _chatTitle);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _chatTitle, topBarHeight + 116);
    
    CONSTRAIN_HEIGHT(_chatImageView, 100);
    CONSTRAIN_WIDTH(_chatImageView, 100);
    CENTER_VIEW_H(self.view, _chatImageView);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _chatImageView, topBarHeight + 8);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self.nextButton setEnabled:NO];
    
    if (range.location > 0 || string.length > 0) {
        [self.nextButton setEnabled:YES];
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAX_CHAT_TITLE_LENGTH || returnKey;
}

#pragma mark - Touch Handling
-(void) doneButtonPressed:(UIButton *)sender
{
    LMPeoplePicker *picker = [[LMPeoplePicker alloc] initWithContacts:_contacts];
    picker.delegate = self;
    [self.navigationController pushViewController:picker animated:YES];
}

-(void)imageViewTapped:(UIGestureRecognizer *)gesture
{
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
    self.chatImageView.image = editedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LMPeoplePicker Delegate
-(void)LMPeoplePicker:(LMPeoplePicker *)picker didFinishPickingPeople:(NSArray *)people
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSMutableArray *groupIds = [[NSMutableArray alloc] initWithObjects:currentUser.objectId, nil];
    
    for (PFUser *user in people) {
        [groupIds addObject:user.objectId];
    }
    
    NSString *groupId = [NSString stringWithFormat:@"Group%@", [NSString lm_createGroupIdWithUsers:groupIds]];
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSDictionary *chatInfo = @{@"groupId" : groupId, @"date" : dateString, @"title" : _chatTitle.text, @"member" : groupIds, @"image" : _chatImageView.image, @"admin" : currentUser.objectId};
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHAT object:chatInfo];
}

@end