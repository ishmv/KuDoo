#import <Foundation/Foundation.h>

@class PFObject;

@interface LMMessages : NSObject

@property (nonatomic, strong, readonly) NSArray *messages;

-(instancetype) initWithGroupId:(NSString *)groupId;
-(void)addMessage:(PFObject *)message;

-(void) loadMessages;

@end

