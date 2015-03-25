#import <Foundation/Foundation.h>

@class  LMChat, PFObject;

typedef void (^LMInitiateChatCompletionBlock)(PFObject *chat, NSError *error);

@interface LMChat : NSObject

+ (instancetype) sharedInstance;

-(void) startChatWithUsers:(NSArray *)users completion:(LMInitiateChatCompletionBlock)completion;
-(void) getChatsForCurrentUser;



@end