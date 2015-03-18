#import <Foundation/Foundation.h>

@class  LMChat, PFObject;

typedef void (^LMInitiateChatCompletionBlock)(NSString *groupId, NSError *error);

@interface LMChat : NSObject

+ (instancetype) sharedInstance;

-(void) startChatWithLMUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion;
-(void) deleteChat:(PFObject *)chat;
-(void) saveChat:(NSString *)chat;

@property (strong, nonatomic, readonly) NSArray *chats;

@end