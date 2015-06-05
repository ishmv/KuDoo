@import Foundation;

@class PFObject, PFUser;

@interface PushNotifications : NSObject

+(void) sendNotificationToUser:(PFUser *)user forMessage:(PFObject *)message;
+(void) sendChatRequestToUser:(PFUser *)user;

@end
