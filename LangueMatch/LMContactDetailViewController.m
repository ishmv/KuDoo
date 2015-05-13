#import "LMContactDetailViewController.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <MessageUI/MessageUI.h>

@interface LMContactDetailViewController () <UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *homeNumber;
@property (nonatomic, strong) NSString *personalEmail;
@property (nonatomic, strong) NSString *workEmail;

@end

@implementation LMContactDetailViewController

#pragma mark - Managing the detail item


- (void)viewDidLoad {
    [super viewDidLoad];

    [_contactDetailsTableView setDelegate:self];
    [_contactDetailsTableView setDataSource:self];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [tapGesture setDelegate:self];
    [_contactImageView setUserInteractionEnabled:YES];
    [self.contactImageView addGestureRecognizer:tapGesture];
    
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
        return 2;
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
            
            UIImage *phoneImage = [UIImage imageNamed:@"phone.png"];
            UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:phoneImage];
            [phoneImageView setFrame:CGRectMake(0, 0, 30, 30)];
            
            switch (indexPath.row) {
                case 0:
                {
                    NSString *mobileNumber = [_contactDetails objectForKey:@"mobileNumber"];
                    cellText = mobileNumber;
                    detailText = @"Mobile Number";
                    
                    if (mobileNumber.length != 0) {
                        self.mobileNumber = [NSString stringWithString:mobileNumber];
                        [cell setAccessoryView:phoneImageView];
                    }
                    
                    break;
                }
                case 1:
                {
                    NSString *homeNumber = [_contactDetails objectForKey:@"homeNumber"];
                    cellText = homeNumber;
                    detailText = @"Home Number";
                    
                    if (homeNumber.length != 0) {
                        self.homeNumber = [NSString stringWithString:homeNumber];
                        [cell setAccessoryView:phoneImageView];
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
                        _personalEmail = [NSString stringWithString:homeEmail];
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
                        _workEmail = [NSString stringWithString:workEmail];
                        [cell setAccessoryView:emailButton];
                    }
                    
                    
                    break;
                }
            }
            break;
        }
        case 2:
            switch (indexPath.row)
        {
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
            switch(indexPath.row)
        {
            case 0:
                cellText = @"Invite to LangueMatch";
                break;
                
            case 1:
                cellText = @"Say Hey";
                break;
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
    
    switch (indexPath.section) {
        case 0:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Contact Method", @"Select Contact Method") message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                switch (indexPath.row) {
                    case 0:
                        [self p_makeCallToNumber:_mobileNumber];
                        break;
                    case 1:
                        [self p_makeCallToNumber:_homeNumber];
                    default:
                        break;
                }
            }];
            
            UIAlertAction *textAction = [UIAlertAction actionWithTitle:@"Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                switch (indexPath.row) {
                    case 0:
                        [self p_sendSMSToNumber:_mobileNumber];
                        break;
                    case 1:
                        [self p_sendSMSToNumber:_homeNumber];
                    default:
                        break;
                }
            }];
            
            for (UIAlertAction *action in @[cancelAction, callAction, textAction]) {
                [alertController addAction:action];
            }
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            break;
        }
        default:
            break;
            
        case 1:
            switch (indexPath.row)
        {
                case 0:
                    [self p_sendMessageToEmail:_personalEmail];
                    break;
                    
                case 1:
                    [self p_sendMessageToEmail:_personalEmail];
                    break;
                default:
                    break;
            }
    case 3:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Contact Method", @"Select Contact Method") message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *emailAction;
            if (_personalEmail.length != 0 || _workEmail.length != 0) {
                emailAction = [UIAlertAction actionWithTitle:@"Send Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if (_personalEmail.length != 0) [self p_sendMessageToEmail:_personalEmail];
                    else [self p_sendMessageToEmail:_workEmail];
                }];
            }
            
            UIAlertAction *textAction;
            if (_mobileNumber.length != 0 || _homeNumber.length != 0) {
                textAction = [UIAlertAction actionWithTitle:@"Send Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if (_mobileNumber.length != 0) [self p_sendSMSToNumber:_mobileNumber];
                    else [self p_sendSMSToNumber:_homeNumber];
                }];
            }
            
            for (UIAlertAction *action in @[cancelAction, emailAction, textAction]) {
                [alertController addAction:action];
            }
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            break;
        }
    }
    
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

-(void) p_sendSMSToNumber:(NSString *)number
{
    if (![MFMessageComposeViewController canSendText]) {
        NSLog(@"Unable to send SMS message.");
    }
    else {
        MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
        [sms setMessageComposeDelegate:self];
        
        [sms setRecipients:[NSArray arrayWithObjects:number, nil]];
        [sms setBody:@"Hey! Check out LangueMatch - Its totally awesome."];
        [self presentViewController:sms animated:YES completion:nil];
    }
}

-(void) p_sendMessageToEmail:(NSString *)email
{
    MFMailComposeViewController *composeEmailVC = [[MFMailComposeViewController alloc] init];
    [composeEmailVC setMailComposeDelegate:self];
    
    [composeEmailVC setToRecipients:@[email]];
    [composeEmailVC setTitle:@"Hey From LangueMatch!"];
    [composeEmailVC setMessageBody:@"Check out LangueMatch - Its totally awesome." isHTML:NO];
    [self presentViewController:composeEmailVC animated:YES completion:nil];
}

#pragma mark - MFMessageCompose Delegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMailCompose Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Touch Handling

-(void)imageViewTapped:(UITapGestureRecognizer *)gesture
{
    IDMPhoto *photo = [[IDMPhoto alloc] initWithImage:_contactImageView.image];
    IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:_contactImageView];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

@end
