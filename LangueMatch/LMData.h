#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
/*
 
 Class used ONLY for testing purposes
 
 */

@interface LMData : NSObject

+ (instancetype) sharedInstance;

-(PFObject *) receiveMessage;

@end
