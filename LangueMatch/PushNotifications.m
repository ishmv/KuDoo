#import "PushNotifications.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@implementation PushNotifications

+(void) sendNotificationToUser:(NSString *)userId forGroupId:(NSString *)groupId
{
    PFUser *receiver = [PFUser objectWithoutDataWithObjectId:userId];
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *pushMessage = [NSString stringWithFormat:@"New Message From %@", currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
//                           @"sound"                 : @"default",
                           @"name"                  : @"LangMatch",
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
    NSString *pushMessage = [NSString stringWithFormat:@"%@ would like to chat!", currentUser.username];
    
    NSDictionary *data = @{
                           @"alert"                 : pushMessage,
                           @"sound"                 : @"default",
                           @"name"                  : @"LangMatch",
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
