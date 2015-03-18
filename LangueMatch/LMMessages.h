#import <Foundation/Foundation.h>

@class PFObject;

@interface LMMessages : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *messages;
@property (strong, nonatomic) NSString *groupID;

-(void)sendMessage:(PFObject *)message;

@end

