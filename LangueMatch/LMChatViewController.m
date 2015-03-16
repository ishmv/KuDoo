#import "LMChatViewController.h"
#import "LMChat.h"
#import "LMMessages.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "LMUsers.h"
#import "LMFriendsListView.h"

@interface LMChatViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) PFObject *chat;
@property (strong, nonatomic) LMFriendsListView *chatView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *sendButton;

@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) LMMessages *messages;

@end

static NSString *const reuseIdentifier = @"Cell";

@implementation LMChatViewController

-(instancetype) initWithGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        self.groupId = groupId;
        
        self.messages = [[LMMessages alloc] initWithGroupId:groupId];
        [self.messages addObserver:self forKeyPath:@"messages" options:0 context:nil];
        
        self.textField = [UITextField new];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIView *view in @[self.sendButton, self.textField]) {
            [self.view addSubview:view];
        }
    }
    return self;
}

#pragma mark - View Controller LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.chatView = [LMFriendsListView new];
    self.chatView.tableView.dataSource = self;
    self.chatView.tableView.delegate = self;
    self.chatView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.chatView];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.chatView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height - 50);
    self.textField.frame = CGRectMake(5, CGRectGetMaxY(self.view.frame) - 50, CGRectGetWidth(self.view.bounds) - 55, 50);
    self.sendButton.frame = CGRectMake(CGRectGetMaxX(self.textField.frame), CGRectGetMaxY(self.view.frame) - 50, 50, 50);
}

-(void)dealloc
{
    [self.messages removeObserver:self forKeyPath:@"messages"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendButtonPressed: (UIButton *)button
{
    PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
    
    PFUser *user = [PFUser currentUser];
    
    message[PF_MESSAGES_USER] = user;
    message[PF_CHAT_TEXT] = self.textField.text;
    message[PF_MESSAGE_SENDER_NAME] = user.username;
    message[PF_MESSAGES_GROUPID] = self.groupId;

    [self.messages addMessage:message];
    self.textField.text = nil;
    [self.chatView.tableView reloadData];
}

-(void) loadMessages
{
    [self.messages loadMessages];
}

#pragma mark - KVO

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.messages && [keyPath isEqualToString:@"messages"]) {
        // We know mediaItems changed.  Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // Someone set a brand new images array
            [self.chatView.tableView reloadData];
            
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            
            NSLog(@"Catch");
        }
    }
}


#pragma mark - UITableView DataSource and Delegate Methods

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    PFObject *message = [self.messages messages][indexPath.row];
    
    cell.textLabel.text = message[@"text"];
    cell.detailTextLabel.text = message[PF_MESSAGE_SENDER_NAME];
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages messages].count;
}



@end
