//
//  LMContacts.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/25/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContacts.h"
#import "LMPerson.h"

#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LMContacts()

@property (strong, nonatomic) NSArray *phoneBookContacts;
@property (strong, nonatomic) NSArray *facebookContacts;

@end

@implementation LMContacts

-(instancetype) init
{
    if (self = [super init]) {
        [self requestPhoneBookAccess];
        [self getFacebookContacts];
    }
    return self;
}


/* -- As of FB graph API v2.0 you can no longer pull the users friend list unless that friend has your app installed --*/
/* --  If facebook ever changes back will re-implement this  -- */

-(void) getFacebookContacts
{
    if (!_facebookContacts) {
        PFUser *currentUser = [PFUser currentUser];
        
        if ([PFFacebookUtils isLinkedWithUser:currentUser]) {
            
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friend-list" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error)
                    {
//                        NSDictionary *userData = (NSDictionary *)result;
                        
                    } else {
                        NSLog(@"Error retreiving facebook contacts");
                    }
                }];
            
            
        } else {
            NSLog(@"Not currently Linked with Facebook");
        }
    }
}


-(void) requestPhoneBookAccess
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
        NSLog(@"Denied");
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        [self getPhoneBookContacts];
        
    } else{
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [cantAddContactAlert show];
                NSLog(@"Just denied");
                return;
                
            }
            //5
            [self getPhoneBookContacts];
        });
        NSLog(@"Not determined");
    }
}

-(void) getPhoneBookContacts
{
    if (!_phoneBookContacts) {
        
        __block NSMutableArray *phoneBookContactList = [NSMutableArray array];
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (addressBook != nil) {
            NSLog(@"Succesful.");
        } else {
            NSLog(@"Error reading Address Book");
        }
        
        //    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        //2
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        //3
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            LMPerson *person = [[LMPerson alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            if (ABPersonHasImageData(contactPerson)) {
                NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatOriginalSize);
                UIImage *personImage = [UIImage imageWithData:contactImageData];
                person.image = personImage;
            }
            
            person.firstName = firstName; person.lastName = lastName;
            person.fullName = fullName;
            
            //email
            //5
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            
            //6
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if (j == 0) {
                    person.homeEmail = email;
                }
                else if (j==1) person.workEmail = email;
            }
            
            //7
            [phoneBookContactList addObject:person];
        }
        
        //8
        CFRelease(addressBook);
        
        self.phoneBookContacts = phoneBookContactList;
        //    });
    }
}


@end
