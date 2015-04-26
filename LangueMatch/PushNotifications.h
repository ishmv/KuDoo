@import Foundation;

@class PFObject;

@interface PushNotifications : NSObject

+(void) sendMessageNotificationForChat:(PFObject *)chat;

@end
