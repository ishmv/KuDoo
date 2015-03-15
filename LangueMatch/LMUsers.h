#import <Foundation/Foundation.h>

@interface LMUsers : NSObject

+(instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray *users;

@end
