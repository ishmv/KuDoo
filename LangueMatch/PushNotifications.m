//
//  PushNotifications.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/30/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

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



@end
