#import "LMContactDetailViewController.h"
#import "Parse/Parse.h"
#import "AppConstant.h"

@interface LMContactDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *contactDetails;
@property (nonatomic, assign) BOOL isLangeMatchUser;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LMContactDetailViewController

static NSString *reuseIdentifier = @"Cell";

-(instancetype) initWithContactDetails:(NSMutableDictionary *)details
{
    if (self = [super init]) {
        self.contactDetails = details;
        
        [self searchLMUsersForMatch];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        for (UIView *view in @[self.tableView]) {
            [self.view addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tableView]-15-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-10-|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *cellText = @"";
    
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cellText = [NSString stringWithFormat:@"Mobile: %@", [_contactDetails objectForKey:@"mobileNumber"]];
                    break;
                case 1:
                    cellText = [NSString stringWithFormat:@"Home Number: %@",[_contactDetails objectForKey:@"homeNumber"]];
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    cellText = [NSString stringWithFormat:@"Home email: %@", [_contactDetails objectForKey:@"homeEmail"]];
                                
                    break;
                case 1:
                    cellText = [NSString stringWithFormat:@"Work email: %@", [_contactDetails objectForKey:@"workEmail"]];

                    break;
            }
            break;

            // IF is LangueMatch user...

            
        default:
            break;
    }
    
    cell.textLabel.text = cellText;

    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.contactDetails[@"firstName"], self.contactDetails[@"lastName"]];
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 2;
    } else {
        return 3;
    }
}


#pragma mark - UITableView Delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    
    if (section == 0) {
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 100)];
        
        UIImageView *contactImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.contactDetails[@"image"]]];
        contactImage.frame = CGRectMake(CGRectGetWidth(self.tableView.bounds)/2 - 50, 0, 100, 100);
        contactImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [headerView addSubview:contactImage];
    }
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 100;
    } else {
        return 50;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"phone";
            break;
        case 1:
            return @"email";
            break;
        case 2:
            return @"LangueMatch";
            break;
            
        default:
            return @"";
            break;
    }
}

#pragma mark - Parse Back End Search

-(void) searchLMUsersForMatch
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_EMAIL equalTo:self.contactDetails[@"homeEmail"]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if (object) {
                self.isLangeMatchUser = YES;
                [self updateContactInfo];
            }
        } else {
            NSLog(@"Error retreiving contact");
        }
    }];
}

-(void)updateContactInfo
{
    
}

@end
