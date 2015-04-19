/* 
 
--- LMMessages.h ---
 
LMMessages coordinates the sending and retreiving of messages to and from the server
 
*/

#import <Foundation/Foundation.h>

@class PFObject, PFUser;

typedef void (^LMFinishedSavingMessage)(PFObject *message, NSError *error);
typedef void  (^LMReceivedNewMessages)(NSArray *messages);

@interface LMMessages : NSObject

+ (instancetype) sharedInstance;

@property (strong, nonatomic, readonly) NSMutableArray *messages;
@property (strong, nonatomic) PFObject *chat;

+(void)saveMessage:(PFObject *)message toGroupId:(NSString *)Id withCompletion:(LMFinishedSavingMessage)completion;
+(void)checkNewMessagesForChat:(PFObject *)chat withCompletion:(LMReceivedNewMessages)completion;

@end

