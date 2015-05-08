@import Foundation;

@class PFObject, PFUser;

@interface PushNotifications : NSObject

+(void) sendNotificationToUser:(PFUser *)user forMessage:(PFObject *)message;

+(void) sendFriendRequest:(PFObject *)request toUser:(PFUser *)user;
+(void) acceptFriendRequest:(PFObject *)request;

//+(void) sendChatRequestToUser:(PFUser *)user;
//+(void) acceptChatRequest:(PFObject *)request;

@end
