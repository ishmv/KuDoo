#import "LMChatViewController.h"
#import "LMChat.h"
#import "LMMessages.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMUsers.h"
#import "LMFriendsListView.h"
#import "LMChatViewCell.h"

@interface LMChatViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) LMFriendsListView *chatView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) UIImageView *chatImage;
@property (strong, nonatomic) UILabel *chatLabel;

@end

static NSString *reuseIdentifier = @"ChatCell";

@implementation LMChatViewController

-(instancetype) initWithGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        self.groupId = groupId;
        
//        [[LMMessages sharedInstance] setGroupID:groupId];
        
        self.textField = [UITextField new];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.delegate = self;
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.sendButton, self.textField]) {
            [self.view addSubview:view];
        }
    }
    return self;
}
//
//#pragma mark - View Controller LifeCycle
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    [[LMMessages sharedInstance] addObserver:self forKeyPath:@"messages" options:0 context:nil];
//    
//    self.chatView = [LMFriendsListView new];
//    self.chatView.tableView.dataSource = self;
//    self.chatView.tableView.delegate = self;
//    self.chatView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.chatView.tableView registerClass:[LMChatViewCell class] forCellReuseIdentifier:reuseIdentifier];
//    self.chatView.userInteractionEnabled = YES;
//    
//    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
//    self.tapGesture.delegate = self;
//    [self.chatView addGestureRecognizer:self.tapGesture];
//    
//    [self.view addSubview:self.chatView];
//}
//
//-(void) viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    self.chatView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height - 50);
//    self.textField.frame = CGRectMake(5, CGRectGetMaxY(self.view.frame) - 50, CGRectGetWidth(self.view.bounds) - 55, 50);
//    self.sendButton.frame = CGRectMake(CGRectGetMaxX(self.textField.frame), CGRectGetMaxY(self.view.frame) - 50, 50, 50);
//}
//
//-(void)dealloc
//{
//    [[LMMessages sharedInstance] removeObserver:self forKeyPath:@"messages"];
//}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
//}
//
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//}
//
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Target Action
//
//-(void)sendButtonPressed: (UIButton *)button
//{
//    PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
//    
//    PFUser *user = [PFUser currentUser];
//    
//    message[PF_MESSAGES_USER] = user;
//    message[PF_CHAT_TEXT] = self.textField.text;
//    message[PF_MESSAGE_SENDER_NAME] = user.username;
//    message[PF_MESSAGES_GROUPID] = self.groupId;
//    message[PF_MESSAGE_SENDER_ID] = user.objectId;
//    
//    [[LMMessages sharedInstance] sendMessage:message withCompletion:^(NSError *error) {
//        self.textField.text = nil;
//        [self.chatView.tableView reloadData];
//    }];
//}
//
//
//#pragma mark - KVO
//
//-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (object == [LMMessages sharedInstance] && [keyPath isEqualToString:@"messages"]) {
//        // We know mediaItems changed.  Let's see what kind of change it is.
//        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
//        
//        if (kindOfChange == NSKeyValueChangeSetting) {
//            // Someone set a brand new images array
//            [self.chatView.tableView reloadData];
//            
//        } else if (kindOfChange == NSKeyValueChangeInsertion ||
//                   kindOfChange == NSKeyValueChangeRemoval ||
//                   kindOfChange == NSKeyValueChangeReplacement) {
//            
//            [self.chatView.tableView reloadData];
//        }
//    }
//}
//
//-(NSArray *) chatMessages
//{
//    return [[LMMessages sharedInstance] messages];
//}
//
//
//#pragma mark - UITableView DataSource and Delegate Methods
//
//-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LMChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
//
//    if (!cell) {
//        cell = [[LMChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//    }
//    
//    PFObject *message = [self chatMessages][indexPath.row];
//    cell.message = message;
//    
//    return cell;
//}
//
//-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self chatMessages].count;
//}

#pragma mark - UITapGesture Delegate

-(void) tapFired:(UITapGestureRecognizer *)gesture
{
    [self.textField resignFirstResponder];
    NSLog(@"Tapped");
}

#pragma mark - Text Field Delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"editing");
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"Done Editing");
}

#pragma mark - Keyboard Notifications

-(void)keyboardWillShow: (NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.chatView.tableView.contentInset = contentInsets;
    self.chatView.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(aRect, self.textField.frame.origin)) {
        [self.chatView.tableView scrollRectToVisible:self.textField.frame animated:YES];
    }
}

-(void)keyboardWillHide: (NSNotification *)aNotificaton
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.chatView.tableView.contentInset = contentInsets;
    self.chatView.tableView.scrollIndicatorInsets = contentInsets;
}

@end
