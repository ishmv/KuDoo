//
//  LMContacts.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/25/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContacts.h"

@implementation LMContacts

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
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
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
    
    predicate = nil;
    
    CFRelease(addressBook);
    return emails;
}

@end
