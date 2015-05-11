#import "LMContactDetailViewController.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

@interface LMContactDetailViewController ()

@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *homeNumber;
@property (nonatomic, strong) NSString *homeEmail;
@property (nonatomic, strong) NSString *workEmail;

@end

@implementation LMContactDetailViewController

#pragma mark - Managing the detail item


- (void)viewDidLoad {
    [super viewDidLoad];

    [_contactDetailsTableView setDelegate:self];
    [_contactDetailsTableView setDataSource:self];
    
    _contactDetailsTableView.backgroundColor = [UIColor lm_cloudsColor];
    _contactDetailsTableView.separatorColor = [UIColor whiteColor];
    _contactDetailsTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    [self p_populateContactData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 2;
    } else if (section == 2)
    {
        return 3;
    }
    else {
        return 1;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Phone Numbers";
            break;
        case 1:
            return @"E-mail Addresses";
            break;
        case 2:
            return @"Address Info";
            break;
        case 3:
            return @"Invite";
            break;
            
        default:
            return @"";
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSString *cellText = @"";
    NSString *detailText = @"";
    
    switch (indexPath.section) {
        case 0:
        {
            
            UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *phoneImage = [UIImage imageNamed:@"phone.png"];
            [callButton setImage:phoneImage forState:UIControlStateNormal];
            [callButton setFrame:CGRectMake(0, 0, 40, 40)];
            [callButton setUserInteractionEnabled:YES];
            [callButton setBackgroundColor:[UIColor clearColor]];
            
            switch (indexPath.row) {
                case 0:
                {
                    NSString *mobileNumber = [_contactDetails objectForKey:@"mobileNumber"];
                    cellText = mobileNumber;
                    detailText = @"Mobile Number";
                    
                    if (mobileNumber.length != 0) {
                        [cell setAccessoryView:callButton];
                    }
                    
                    break;
                }
                case 1:
                {
                    NSString *homeNumber = [_contactDetails objectForKey:@"homeNumber"];
                    cellText = homeNumber;
                    detailText = @"Home Number";
                    
                    if (homeNumber.length != 0) {
                        [callButton addTarget:self action:@selector(p_makeCallToNumber:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell setAccessoryView:callButton];
                    }
                    break;
                }
            }
            break;
        }
        case 1:
        {
            
            UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *emailImage = [UIImage imageNamed:@"invitation.png"];
            [emailButton setImage:emailImage forState:UIControlStateNormal];
            [emailButton setFrame:CGRectMake(0, 0, 50, 50)];
            [emailButton setUserInteractionEnabled:YES];
    
            switch (indexPath.row) {
                case 0:
                {
                    NSString *homeEmail = [_contactDetails objectForKey:@"homeEmail"];
                    cellText = homeEmail;
                    detailText = @"Personal E-mail";
                    
                    if (homeEmail.length != 0) {
                        [cell setAccessoryView:emailButton];
                    }
                    
                    break;
                }
                case 1:
                {
                    NSString *workEmail = [_contactDetails objectForKey:@"workEmail"];
                    cellText = workEmail;
                    detailText = @"Work E-mail";
                    
                    if (workEmail.length != 0) {
                        [cell setAccessoryView:emailButton];
                    }
                    
                    
                    break;
                }
            }
            break;
        }
        case 2:
            switch (indexPath.row) {
                case 0:
                    cellText = [_contactDetails objectForKey:@"address"];
                    detailText = @"Street Address";
                    break;
                case 1:
                    cellText = [_contactDetails objectForKey:@"zipCode"];
                    detailText = @"ZIP Code";
                    break;
                case 2:
                    cellText = [_contactDetails objectForKey:@"city"];
                    detailText = @"City";
                    break;
            }
            break;
            
        case 3:
        {
            cellText = @"Invite to LangueMatch";
        }
            
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor lm_tealBlueColor];
    
    cell.textLabel.text = cellText;
    cell.textLabel.textColor = [UIColor lm_cloudsColor];
    
    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.textColor = [UIColor lm_cloudsColor];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Private Methods

-(void) p_populateContactData
{
    NSString *contactFullName = [NSString stringWithFormat:@"%@", [_contactDetails objectForKey:@"name"]];
    
    [_labelContactName setText:contactFullName];
    
    if ([_contactDetails objectForKey:@"image"]) {
        NSData *imageData = _contactDetails[@"image"];
        [_contactImageView setImage:[UIImage imageWithData:imageData]];
    }
    
    [_contactDetailsTableView reloadData];
}

-(void) p_makeCallToNumber:(NSString *)number
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
}
@end
