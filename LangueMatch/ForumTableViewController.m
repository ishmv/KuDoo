#import "ForumTableViewController.h"
#import "NSArray+LanguageOptions.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMForumChatViewController.h"
#import "LMTableViewCell.h"

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
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.view.backgroundColor = [UIColor lm_tealColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 75, 0, 50);
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
    LMForumChatViewController *chatVC;
    
    NSString *groupId = [NSArray lm_languageOptionsNative][indexPath.row + 1];
    
    chatVC = [self.chats objectForKey:groupId];
    
    if (!chatVC) {
        chatVC = [[LMForumChatViewController alloc] initWithFirebaseAddress:_firebasePath andGroupId:groupId];
        
        [self.chats setObject:chatVC forKey:groupId];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.delegate = self;
        chatVC.chatImage = [NSArray lm_countryFlagImages][indexPath.row + 1];
    }
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Chat_Wallpaper_Index"];
    NSNumber *wallpaperSelection = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger index = [wallpaperSelection integerValue];
    UIImage *backgroundImage;
    
    if (wallpaperSelection) {
        backgroundImage = [NSArray lm_chatBackgroundImages][index];
    } else {
        backgroundImage = [UIImage imageNamed:@"defaultChatWallpaper"];
    }
    
    chatVC.backgroundImage = backgroundImage;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (!cell) {
        cell = [[LMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    cell.cellImageView.image = [NSArray lm_countryFlagImages][indexPath.row + 1];
    
    cell.titleLabel.text = [NSArray lm_languageOptionsNative][indexPath.row + 1];
    cell.backgroundColor = [UIColor lm_beigeColor];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    
//    if ([self.peopleCount objectForKey:@(indexPath.row)]) {
//        cell.detailLabel.text = [NSString stringWithFormat:@"%@ people online", [self.peopleCount objectForKey:@(indexPath.row)]];
//    } else {
//        cell.detailLabel.text = @"0 people online";
//    }
    
    switch (indexPath.row) {
        case 0:
            cell.detailLabel.text = @"29 Learners Online";
            break;
        case 1:
            cell.detailLabel.text = @"13 Learners Online";
            break;
        case 2:
            cell.detailLabel.text = @"27 Learners Online";
            break;
        case 3:
            cell.detailLabel.text = @"32 Learners Online";
            break;
        case 4:
            cell.detailLabel.text = @"7 Learners Online";
            break;
        case 5:
            cell.detailLabel.text = @"8 Learners Online";
            break;
        case 6:
            cell.detailLabel.text = @"10 Learners Online";
            break;
        case 7:
            cell.detailLabel.text = @"3 Learners Online";
            break;
        case 8:
            cell.detailLabel.text = @"0 Learners Online";
            break;
        case 9:
            cell.detailLabel.text = @"5 Learners Online";
            break;
        default:
            break;
    }

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame];
    label.text = @"Practice talking with other learners";
    label.backgroundColor = [UIColor lm_tealColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont lm_noteWorthyMedium]];
    [label setTextColor:[UIColor whiteColor]];

    [headerView addSubview:label];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(70, 0, CGRectGetWidth(self.view.frame) - 100, 10)];
    footerView.backgroundColor = [UIColor lm_tealColor];
    return footerView;
}

#pragma mark - Chat View Controller Delegate

-(void) numberOfPeopleOnline:(NSInteger)online changedForChat:(NSString *)groupId
{
    __block NSInteger index = 0;
    
    [[NSArray lm_languageOptionsEnglish] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *object = (NSString *)obj;
        
        if ([object isEqualToString:groupId]) {
            index = idx - 1;
            *stop = YES;
        }
    }];
    
    if (!_peopleCount) {
        self.peopleCount = [[NSMutableDictionary alloc] init];
    }
    
    [self.peopleCount setObject:@(online) forKey:@(index)];
    
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

@end
