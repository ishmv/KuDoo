#import <Foundation/Foundation.h>

@interface LMData : NSObject

+ (instancetype) sharedInstance;

@property (strong, nonatomic, readonly) NSArray *chats;
@property (strong, nonatomic, readonly) NSArray *friends;

-(void)checkServerForNewChats;

@end
