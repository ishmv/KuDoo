//
//  MasterViewController.m
//  LMAddressBook
//
//  Created by Travis Buttaccio on 5/10/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContactMasterViewController.h"
#import "LMContactDetailViewController.h"

@interface LMContactMasterViewController ()

@property (strong, nonatomic) ABPeoplePickerNavigationController *addressBookController;

@end

@implementation LMContactMasterViewController

-(instancetype) init
{
    if (self = [super init]) {
        _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
        [_addressBookController setPeoplePickerDelegate:self];
        
        [self.view addSubview:_addressBookController.view];
        
        UITabBarItem *barItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
        self.tabBarItem = barItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ABPeoplePickerNavController Delegate

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc] init];
    
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
    
    [contactInfoDict setObject:name forKey:@"name"];
    
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (int i = 0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneNumber = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneNumber forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneNumber forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneNumber);
    }
    
    CFRelease(phonesRef);
    
    ABMultiValueRef emailRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (int i = 0; i < ABMultiValueGetCount(emailRef); i++) {
        CFStringRef currenEmailLabel = ABMultiValueCopyLabelAtIndex(emailRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailRef, i);
        
        if (CFStringCompare(currenEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
        }
        
        if (CFStringCompare(currenEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        
        CFRelease(currenEmailLabel);
        CFRelease(currentEmailValue);
    }
    
    CFRelease(emailRef);
    
    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    if (ABMultiValueGetCount(addressRef) > 0) {
        NSDictionary *addressDict = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
        
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressStreetKey] forKey:@"address"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressZIPKey] forKey:@"zipCode"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressCityKey] forKey:@"city"];
    }
    
    CFRelease(addressRef);
    
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
    LMContactDetailViewController *LMContactVC = [sb instantiateViewControllerWithIdentifier:@"contactDetail"];
    [LMContactVC setContactDetails:contactInfoDict];
    [self.navigationController pushViewController:LMContactVC animated:YES];
}

@end
