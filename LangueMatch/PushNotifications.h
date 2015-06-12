@import Foundation;

@interface PushNotifications : NSObject

+(void) sendNotificationToUser:(NSString *)userId;
+(void) sendChatRequestToUser:(NSString *)userId;

@end
