//
//  NSString+Chats.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/4/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "NSString+Chats.h"

#import <Parse/Parse.h>

@implementation NSString (Chats)

+(NSString *) lm_createGroupIdWithUsers:(NSArray *)users
{
    NSArray *orderedUsers = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PFUser *user1 = (PFUser *)obj1;
        PFUser *user2 = (PFUser *)obj2;
        
        NSString *id1 = user1.objectId;
        NSString *id2 = user2.objectId;
        
        if ([id1 compare:id2] < 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([id1 compare:id2] > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableString *groupId = [NSMutableString new];
    
    for (PFUser *user in orderedUsers) {
        [groupId appendString:user.objectId];
    }
    
    return groupId;
}

@end
