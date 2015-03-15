#import <Foundation/Foundation.h>

@class LMChat, PFUser;

@interface LMMessage : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) PFUser *sender;
@property (strong, nonatomic) LMChat *chat;

@end
