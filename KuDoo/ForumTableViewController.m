#import "ForumTableViewController.h"
#import "NSArray+LanguageOptions.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMForumChatViewController.h"
#import "LMForumTableViewCell.h"
#import "Utility.h"
#import "AppConstant.h"
#import "NSDate+Chats.h"
#import "NSString+Chats.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface ForumTableViewController () <LMChatViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *chats;
@property (nonatomic, strong) NSMutableDictionary *peopleCount;
@property (nonatomic, copy, readwrite) NSString *firebasePath;
@property (nonatomic, strong) NSMutableDictionary *lastMessages;

@end

@implementation ForumTableViewController

static NSString *reuseIdentifier = @"reuseIdentifier";

#pragma mark - View Controller Lifecycle

-(instancetype) initWithFirebaseAddress:(NSString *)path
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _firebasePath = [NSString stringWithFormat:@"%@/forums", path];
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"globe"]];
        self.tabBarItem.title = NSLocalizedString(@"Forums", @"forums");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_chats) {
        self.chats = [[NSMutableDictionary alloc] init];
    }
    
    [self p_loadForumChats];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealBlueColor];
    
    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont lm_robotoLightLarge]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:[NSString stringWithFormat:@"KuDoo %@", NSLocalizedString(@"Forums", @"forums")]];
        label;
    });

    [self.navigationItem setTitleView:titleLabel];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    [self.tableView registerClass:[LMForumTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorColor = [UIColor whiteColor];
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
    return [NSArray lm_languageOptionsEnglish].count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMForumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!cell) {
        cell = [[LMForumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *groupId = [NSArray lm_languageOptionsNative][indexPath.section + 1];
    
    if ([self.lastMessages objectForKey:groupId]) {
        NSDictionary *lastMessage = [self.lastMessages objectForKey:groupId];
        NSString *text = lastMessage[@"text"];
        NSString *senderDisplayName = lastMessage[@"senderDisplayName"];
        NSString *detailText = ([senderDisplayName isEqualToString:[PFUser currentUser][PF_USER_DISPLAYNAME]]) ? [NSString stringWithFormat:@"You: %@", text] : [NSString stringWithFormat:@"%@: %@", senderDisplayName, text];
        cell.infoLabel.text = detailText;
    } else {
        cell.infoLabel.text = @"";
    }

    cell.cellImageView.image = [NSArray lm_countryFlagImages][indexPath.section + 1];
    cell.titleLabel.text = [NSArray lm_languageOptionsFull][indexPath.section + 1];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSString *localNumber = [formatter stringFromNumber:[NSArray lm_nativeSpeakers][indexPath.section + 1]];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@", localNumber, NSLocalizedString(@"Million Speakers Worldwide", @"million speakers worldwide")];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[NSArray lm_countryBackgroundImages][indexPath.section + 1]];
    cell.backgroundView = backgroundView;
    
    if ([self.peopleCount objectForKey:groupId]) {
        NSNumber *personCount = (NSNumber *)[self.peopleCount objectForKey:groupId];
        cell.accessoryLabel.text = [NSString stringWithFormat:@"%@", personCount];
    } else {
        cell.accessoryLabel.text = [NSString stringWithFormat:@"0"];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 10)];
    footerView.backgroundColor = [UIColor lm_beigeColor];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *groupId = [NSArray lm_languageOptionsNative][indexPath.row + 1];
    [self.navigationController pushViewController:[self p_createChatWithGroupId:groupId] animated:YES];
}


#pragma mark - LMChatViewController Delegate

-(void) numberOfPeopleOnlineChanged:(NSInteger)peopleCount forChatViewController:(LMChatViewController *)controller
{
    if (!_peopleCount) {
        self.peopleCount = [[NSMutableDictionary alloc] init];
    }
    
    [self.peopleCount setObject:[NSNumber numberWithInteger:peopleCount] forKey:controller.groupId];
    
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

-(void) updateLastMessage:(NSDictionary *)message forChatViewController:(LMChatViewController *)controller
{
    if (!_lastMessages) {
        self.lastMessages = [[NSMutableDictionary alloc] init];
    }
    
    [self.lastMessages setObject:message forKey:controller.groupId];
    [self.tableView reloadData];
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
    chatVC.titleLabel.text = groupId;
    
    return chatVC;
}

#pragma mark - touch Handling
-(void) addButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertController *addChatAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Chat", @"add chat") message:NSLocalizedString(@"Suggest a language", @"suggest a language") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *languageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Suggest", @"suggest") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
                hud.color = [UIColor whiteColor];
                [hud hide:YES afterDelay:2.0];
            }
        }];
    }];
    
    for (UIAlertAction *action in @[cancelAction, languageAction]) {
        [addChatAlert addAction:action];
    }
    
    [addChatAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Language", @"language");
    }];
    
    [self presentViewController:addChatAlert animated:YES completion:nil];
}

@end