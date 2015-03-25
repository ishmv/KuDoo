//
//  LMContacts.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/25/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContacts.h"

@implementation LMContacts


-(NSArray *)contactsContainingPhoneNumber:(NSString *)phoneNumber {
    /*
     
     Returns an array of contacts that contain the phone number
     
     */
    
    // Remove non numeric characters from the phone number
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonPhoneProperty);
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([contactPhoneNumber rangeOfString:phoneNumber].location != NSNotFound) {
                result = YES;
                break;
            }
        }
        CFRelease(phoneNumbers);
        return result;
    }];
    
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    
    return filteredContacts;
}

+(NSArray *)getContactEmails
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
    
    NSLog(@"%@", addressBook);
    
    // Requests access to address book data from the user
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef emailsRef = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonEmailProperty);
        BOOL result = NO;
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(emailsRef); i++) {
            NSString *contactEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emailsRef, i);
            
            [emails addObject:contactEmail];
            
        }
        CFRelease(emailsRef);
        return result;
    }];
    
//    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
//    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
//        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
//        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
//        
//        if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
//            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
//        }
//        
//        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
//            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
//        }
//        
//        CFRelease(currentEmailLabel);
//        CFRelease(currentEmailValue);
//        
//    }
//    CFRelease(emailsRef);
    
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);

    return emails;
}

@end
