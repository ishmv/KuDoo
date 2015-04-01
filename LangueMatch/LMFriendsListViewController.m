#import "LMFriendsListViewController.h"
#import "LMFriendsListView.h"
#import "LMUsers.h"
#import "LMFriendsListViewCell.h"
#import "LMUserProfileViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "LMContactDetailViewController.h"

#import "LMData.h"

@interface LMFriendsListViewController () <LMFriendsListViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) LMFriendsListView *friendsView;
@property (strong, nonatomic) ABPeoplePickerNavigationController *addressBookController;
@property (strong, nonatomic) LMContactDetailViewController *contactDetails;

@end

static NSString *reuseIdentifier = @"FriendCell";

@implementation LMFriendsListViewController

-(instancetype)init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-305-palm-tree.png"]];
        self.tabBarItem.title = @"Friends";
    }
    return self;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.friendsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_friendsView.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addContact = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactButtonPressed)];
    [self.navigationItem setRightBarButtonItem:addContact];
    
    self.friendsView = [[LMFriendsListView alloc] init];
    self.friendsView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.friendsView.delegate = self;
    [self.friendsView.tableView registerClass:[LMFriendsListViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.friendsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{

}

#pragma mark - UITableView Data Source

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMFriendsListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LMFriendsListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    PFUser *user = [self friends][indexPath.row];
    cell.user = user;
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self friends].count;
}


#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Show User Profile
    //Option to start chat at bottom
    
    LMUserProfileViewController *userVC = [[LMUserProfileViewController alloc] init];
    userVC.user = [self friends][indexPath.row];
    [self.navigationController pushViewController:userVC animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - KVO on Users

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [LMUsers sharedInstance] && [keyPath isEqualToString:@"users"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.friendsView.tableView reloadData];
        }
    }
}

-(NSArray *) friends
{
    return [[LMData sharedInstance] friends];
}

#pragma mark - Target Action

-(void) addContactButtonPressed
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
        NSLog(@"Denied");
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        self.addressBookController = [[ABPeoplePickerNavigationController alloc] init];
        [self.addressBookController setPeoplePickerDelegate:self];
        [self.navigationController presentViewController:self.addressBookController animated:YES completion:nil];
        
    } else{
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [cantAddContactAlert show];
                NSLog(@"Just denied");
                return;
                
            }
            //5
            NSLog(@"Just authorized");
        });
        NSLog(@"Not determined");
    }
}

#pragma mark - ABPeoplePickerNavigationController Delegate

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSLog(@"Selected Person");
    
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc] initWithObjects:@[@"", @"", @"", @"", @"", @"", @""] forKeys:@[@"firstName", @"lastName", @"homeNumber", @"mobileNumber", @"image", @"homeEmail", @"workEmail"]];
    
    CFTypeRef generalCFObject;
    generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey: @"lastName"];
        CFRelease(generalCFObject);
    }
    
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"mobileNumber"];
    }
    
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
        }
        
        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        
        CFRelease(currentEmailLabel);
        CFRelease(currentEmailValue);
        
    }
    CFRelease(emailsRef);
    
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    self.contactDetails = [[LMContactDetailViewController alloc] initWithContactDetails:contactInfoDict];
    self.contactDetails.title = [NSString stringWithFormat:@"%@ %@", contactInfoDict[@"firstName"], contactInfoDict[@"lastName"]];
    [self.navigationController pushViewController:self.contactDetails animated:YES];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
