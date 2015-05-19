#import "LMFriendSelectionViewController.h"
#import "AppConstant.h"
#import "TableViewCellStyleValue1.h"
#import "LMFriendsModel.h"
#import "LMFriendListCell.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

#import <Parse/Parse.h>

@interface LMFriendSelectionViewController ()

@property (copy, nonatomic) void (^LMCompletedFriendSelection)(NSArray *friends);

@property (strong, nonatomic) NSMutableArray *selectedFriendList;

@end

@implementation LMFriendSelectionViewController

static NSString *const reuseIdentifier = @"cellIdentifier";

-(instancetype) initWithCompletion:(LMCompletedFriendSelection)completion
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _LMCompletedFriendSelection = completion;
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LMFriendListCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView setAllowsMultipleSelection:YES];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.selectedFriendList = nil;
}

-(void)dealloc
{
    self.selectedFriendList = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[LMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    PFUser *user = self.friendList[indexPath.row];
    cell.user = user;
    cell.detailLabel.text = @"";
    cell.accessoryLabel.text = @"";
    cell.titleLabel.text = user.username;
    cell.titleLabel.font = [UIFont lm_noteWorthyMedium];
    cell.titleLabel.textColor = [UIColor lm_wetAsphaltColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Target Action Methods
-(void)cancelButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonPressed:(UIButton *)sender
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    NSMutableArray *selectedFriends = [NSMutableArray new];
    
    for (NSIndexPath *indexPath in selectedRows){
        [selectedFriends addObject:self.friendList[indexPath.row]];
    }
    
    self.LMCompletedFriendSelection(selectedFriends);
}

#pragma mark - Helper Methods

-(NSArray *) friendList
{
    return [[LMFriendsModel sharedInstance] friendList];
}

@end
