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

@property (strong, nonatomic, readonly) NSMutableArray *messages;
@property (strong, nonatomic) PFObject *chat;

-(void)sendMessage:(PFObject *)message withCompletion:(LMFinishedSendingMessage)completion;
-(void)checkForNewMessagesWithCompletion:(LMReceivedNewMessage)completion;

@end

