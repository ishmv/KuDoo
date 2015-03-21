#import <Foundation/Foundation.h>

@class PFObject, PFUser;

typedef void (^LMFinishedSendingMessage)(NSError *error);

@interface LMMessages : NSObject

-(instancetype) initWithGroupID:(NSString *)groupId;

@property (nonatomic, strong, readonly) NSArray *chatMembers;
@property (nonatomic, strong) NSMutableArray *messages;

-(void)sendMessage:(PFObject *)message withCompletion:(LMFinishedSendingMessage)completion;
-(void)checkForNewMessages;

@end

