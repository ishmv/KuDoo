#import "PushNotifications.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@implementation PushNotifications

+(void) sendNotificationToUser:(NSString *)userId forGroupId:(NSString *)groupId
{
    PFUser *receiver = [PFUser objectWithoutDataWithObjectId:userId];
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *pushMessage = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"New message from",@"new message from"), currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"Tink.caf",
//                           @"name"                  : @"KuDoo",
                           @"groupId"               : groupId,
                           @"content-available"     : @1,
                           @"badge"                 : @"increment",
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:receiver];
    
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

+(void) sendChatRequestToUser:(NSString *)userId forGroupId:(NSString *)groupId
{
    PFUser *receiver = [PFUser objectWithoutDataWithObjectId:userId];
    PFUser *currentUser = [PFUser currentUser];
    NSString *pushMessage = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"New chat from", @"New chat from"), currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"default",
                           @"name"                  : @"Kudoo",
                           @"groupId"               : groupId,
                           @"content-available"     : @1,
                           @"badge"                 : @"increment",
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:receiver];
    
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
