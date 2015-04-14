#import <Foundation/Foundation.h>

@interface LMData : NSObject

+ (instancetype) sharedInstance;

-(void) checkLocalDataStoreForChats;
-(void) updateChatList;

@end
