#import "LMLanguageOptionsTableView.h"
#import "NSArray+LanguageOptions.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

@interface LMLanguageOptionsTableView ()

@property (strong, nonatomic) NSArray *languageOptions;

@end

@implementation LMLanguageOptionsTableView

static NSString *const reuseIdentifier = @"reuseIdentifier";

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        _languageOptions = [NSArray lm_languageOptionsNative];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.languageOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = self.languageOptions[indexPath.row];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Back", @"back");
    }
    
    cell.backgroundColor = [UIColor lm_orangeColor];
    cell.textLabel.font = [UIFont lm_robotoLightMessage];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 69)];
    headerView.backgroundColor = [UIColor clearColor];

    return headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate LMLanguageOptionsTableView:self didSelectLanguage:indexPath.row];
}

@end
