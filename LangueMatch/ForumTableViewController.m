#import "ForumTableViewController.h"
#import "NSArray+LanguageOptions.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMForumChatViewController.h"
#import "LMTableViewCell.h"
#import "Utility.h"
#import "AppConstant.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface ForumTableViewController () <LMChatViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *chats;
@property (nonatomic, strong) NSMutableDictionary *peopleCount;
@property (nonatomic, copy, readwrite) NSString *firebasePath;

@end

@implementation ForumTableViewController

static NSString *reuseIdentifier = @"reuseIdentifier";

#pragma mark - View Controller Lifecycle

-(instancetype) initWithFirebaseAddress:(NSString *)path
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _firebasePath = [NSString stringWithFormat:@"%@/forums", path];
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"globe"]];
        self.tabBarItem.title = @"Forums";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_chats) {
        self.chats = [[NSMutableDictionary alloc] init];
    }
    
    [self p_loadForumChats];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_noteWorthyLargeBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Forums", @"Forums")];
    [self.navigationItem setTitleView:titleLabel];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 90, 0, 50);
    [self.tableView registerClass:[LMTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [NSArray lm_languageOptionsEnglish].count - 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupId = [NSArray lm_languageOptionsNative][indexPath.row + 1];
    [self.navigationController pushViewController:[self p_createChatWithGroupId:groupId] animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *groupId = [NSArray lm_languageOptionsNative][indexPath.row + 1];

    cell.cellImageView.image = [NSArray lm_countryFlagImages][indexPath.row + 1];
    cell.titleLabel.text = groupId;
    
    cell.backgroundColor = [UIColor lm_beigeColor];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    
    if ([self.peopleCount objectForKey:groupId]) {
        NSNumber *personCount = (NSNumber *)[self.peopleCount objectForKey:groupId];
        
        if ([personCount integerValue] == 1) {
            cell.detailLabel.text = NSLocalizedString(@"1 learner online", "1 learner online");
        } else {
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@", personCount, NSLocalizedString(@"learners online",@"learners online")];
        }
    } else {
        cell.detailLabel.text = NSLocalizedString(@"No one online", "No one online");
    }

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

#pragma mark - Chat View Controller Delegate

-(void) numberOfPeopleOnline:(NSInteger)online changedForChat:(NSString *)groupId
{
    if (!_peopleCount) {
        self.peopleCount = [[NSMutableDictionary alloc] init];
    }
    
    [self.peopleCount setObject:[NSNumber numberWithInteger:online] forKey:groupId];
    
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - Private Methods

-(void) p_loadForumChats
{
    for (int i = 1; i < [NSArray lm_languageOptionsNative].count; i++) {
        [self p_createChatWithGroupId:[NSArray lm_languageOptionsNative][i]];
    }
}

-(LMForumChatViewController *) p_createChatWithGroupId:(NSString *)groupId
{
    LMForumChatViewController *chatVC;
    
    chatVC = [self.chats objectForKey:groupId];
    
    if (!chatVC) {
        chatVC = [[LMForumChatViewController alloc] initWithFirebaseAddress:_firebasePath andGroupId:groupId];
        [self.chats setObject:chatVC forKey:groupId];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.delegate = self;
    }
    
    UIImage *backgroundImage;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Chat_Wallpaper_Index"];
    
    if (data != NULL) {
        NSNumber *wallpaperSelection = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        backgroundImage = [NSArray lm_chatBackgroundImages][[wallpaperSelection integerValue]];
    } else {
        backgroundImage = [UIImage imageNamed:@"auroraBorealis"];
    }
    
    chatVC.backgroundImage = backgroundImage;
    
    return chatVC;
}

#pragma mark - touch Handling
-(void) addButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertController *addChatAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Chat", @"Add Chat") message:NSLocalizedString(@"Suggest a language to be added", @"Suggest a language to be added") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *languageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Suggest", @"Suggest") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *emailTextField = addChatAlert.textFields[0];
        
        PFObject *suggestion = [PFObject objectWithClassName:LM_LANGUAGE_SUGGESTION];
        suggestion[LM_LANGUAGE] = emailTextField.text;
        suggestion[PF_USER_CLASS_NAME] = [PFUser currentUser];
        
        [suggestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil) {
                NSLog(@"error sending report user request %@", error.description);
            }
            else
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = NSLocalizedString(@"Thank you - Suggestion Sent", @"Thank you - Suggestion Sent");
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:2.0];
            }
        }];
    }];
    
    for (UIAlertAction *action in @[cancelAction, languageAction]) {
        [addChatAlert addAction:action];
    }
    
    [addChatAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Reason", @"Reason");
    }];
    
    [self presentViewController:addChatAlert animated:YES completion:nil];
}

@end
