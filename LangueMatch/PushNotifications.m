#import "PushNotifications.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@implementation PushNotifications

+(void) sendNotificationToUser:(PFUser *)user forMessage:(PFObject *)message
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *pushMessage = [NSString stringWithFormat:@"Message From %@", currentUser.username];
    NSString *messageId = message.objectId;
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"default",
                           @"name"                  : @"LangueMatch",
                           @"badge"                 : @"Increment",
                           PF_MESSAGE_ID            : messageId,
                           @"content-available"     : @1,
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}

+(void) sendChatRequestToUser:(PFUser *)user
{
    
}

+(void) sendTypingNotification:(BOOL)isTyping toUser:(PFUser *)user forChat:(PFObject *)chat
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *chatGroupdId = chat[PF_CHAT_GROUPID];
    
    NSDictionary *data = @{
                           NOTIFICATION_USER_TYPING     : @(isTyping),
                           PF_CHAT_GROUPID              : chatGroupdId,
                           PF_USER_USERNAME             : currentUser.username,
                           @"content-available"         : @0
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}

+(void) sendFriendRequest:(PFObject *)request toUser:(PFUser *)user
{
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *requestId = request.objectId;
    NSString *pushMessage = [NSString stringWithFormat:@"Friend Request From %@", currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"default",
                           @"name"                  : @"LangueMatch",
                           @"content-available"     : @1,
                           PF_FRIEND_REQUEST        : requestId
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}

+(void) acceptFriendRequest:(PFObject *)request;
{
    PFUser *requestSender = request[PF_FRIEND_REQUEST_SENDER];
    PFUser *currentUser = [PFUser currentUser];
    NSString *requestId = request.objectId;
    
    NSString *pushMessage = [NSString stringWithFormat:@"%@ Accepted Your Friend Request", currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"default",
                           @"name"                  : @"LangueMatch",
                           @"content-available"     : @1,
                           PF_FRIEND_REQUEST        : requestId
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:requestSender];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Error Sending Push");
        }
    }];
}

@end
