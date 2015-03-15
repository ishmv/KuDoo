#import <Foundation/Foundation.h>

@interface LMChat : NSObject

+(instancetype) sharedInstance;

@property (strong, nonatomic, readonly) NSArray *messages;
@property (strong, nonatomic) NSArray *users;

@end
