@import Foundation;

@class PFObject, PFUser;

@interface PushNotifications : NSObject

+(void) sendMessageNotificationToUser:(PFUser *)user forChat:(PFObject *)chat;

@end
