#import <Foundation/Foundation.h>

@interface LMData : NSObject

+ (instancetype) sharedInstance;

@property (strong, nonatomic, readonly) NSMutableArray *chats;
@property (strong, nonatomic, readonly) NSMutableArray *friends;

-(void) checkLocalDataStoreForChats;
-(void) updateChatList;

@end
