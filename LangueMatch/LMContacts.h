#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface LMContacts : NSObject

@property (strong, nonatomic, readonly) NSArray *phoneBookContacts;
@property (strong, nonatomic, readonly) NSArray *facebookContacts;

@end
