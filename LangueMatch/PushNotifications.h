@import Foundation;

@class PFObject, PFUser;

@interface PushNotifications : NSObject

+(void) sendNotificationToUser:(PFUser *)user forMessage:(PFObject *)message;

+(void) sendFriendRequestToUser:(PFUser *)user;

+(void) sendChatRequestToUser:(PFUser *)user;

@end
