@import Foundation;

@interface PushNotifications : NSObject

+(void) sendNotificationToUser:(NSString *)userId forGroupId:(NSString *)groupId;
+(void) sendChatRequestToUser:(NSString *)userId forGroupId:(NSString *)groupId;

@end
