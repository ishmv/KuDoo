#import <Foundation/Foundation.h>

@class LMSyncEngine;

@interface LMSyncEngine : NSObject

+(LMSyncEngine *)sharedEngine;

-(void)registerNSManagedObjectClassToSync:(Class)aClass;
-(void)startSync;

@property (nonatomic, assign) BOOL syncInProgress;

@end
