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

+(void) sendMessageNotificationForChat:(PFObject *)chat
{
    NSMutableArray *chatMembers = [chat[PF_CHAT_MEMBERS] mutableCopy];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *pushMessage = [NSString stringWithFormat:@"Message From %@", currentUser.username];
    NSString *groupId = [chat objectForKey:PF_CHAT_GROUPID];
    NSDictionary *data = @{
                           @"alert" : pushMessage,
                           @"name" : @"LangueMatch",
                           @"badge" : @"Increment",
                           PF_CHAT_GROUPID : groupId,
                           @"content-available" : @1
                           };
    
    PFQuery *queryInstallation = [PFInstallation query];
    
    for (PFUser *user in chatMembers) {
        if (user != [PFUser currentUser]) {
            
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
    }
}

@end
