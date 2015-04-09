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

@interface LMContacts()

@property (strong, nonatomic) NSArray *phoneBookContacts;
@property (strong, nonatomic) NSArray *facebookContacts;

@end

@implementation LMContacts

-(instancetype) init
{
    if (self = [super init]) {
        [self getPhoneBookContacts];
    }
    return self;
}

+(NSArray *)getPhoneBookEmails
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSMutableArray *emails = [NSMutableArray array];
    
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef emailsRef = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonEmailProperty);
        BOOL result = NO;
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(emailsRef); i++)
        {
            NSString *contactEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emailsRef, i);
            [emails addObject:contactEmail];
        }
        CFRelease(emailsRef);
        return result;
    }];
    
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    
    filteredContacts = nil;
    CFRelease(addressBook);
    return emails;
}

- (void) getPhoneBookContacts
{
    __block NSMutableArray *phoneBookContactList = [NSMutableArray array];
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil) {
        NSLog(@"Succesful.");
    } else {
        NSLog(@"Error reading Address Book");
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
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
    });
}

+(NSArray *)getFaceBookEmails
{
    return nil;
}

@end
