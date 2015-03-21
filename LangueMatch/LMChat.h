#import <Foundation/Foundation.h>

@class  LMChat, PFObject;

typedef void (^LMInitiateChatCompletionBlock)(NSString *groupId, NSError *error);

@interface LMChat : NSObject

+ (instancetype) sharedInstance;

-(void) startChatWithUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion;
-(void) getChatsForCurrentUser;

@property (strong, nonatomic, readonly) NSArray *chats;

@end