#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface LMContacts : NSObject

+(NSArray *)getPhoneBookEmails;
+(NSArray *)getFaceBookEmails;

+(NSArray *)getPhoneBookContacts;

@property (strong, nonatomic, readonly) NSArray *phoneBookContacts;
@property (strong, nonatomic, readonly) NSArray *facebookContacts;

@end
