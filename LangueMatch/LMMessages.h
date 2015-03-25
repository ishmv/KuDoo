/* 
 
--- LMMessages.h ---
 
LMMessages coordinates the sending and retreiving of messages to and from the server
 
*/

#import <Foundation/Foundation.h>

@class PFObject, PFUser;

typedef void (^LMFinishedSendingMessage)(NSError *error);
typedef void  (^LMReceivedNewMessage)(int newMessageCount);

@interface LMMessages : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *chatMembers;
@property (nonatomic, strong) NSMutableArray *messages;
@property (strong, nonatomic) NSString *groupID;

-(void)sendMessage:(PFObject *)message withCompletion:(LMFinishedSendingMessage)completion;
-(void)checkForNewMessagesWithCompletion:(LMReceivedNewMessage)completion;

@end

