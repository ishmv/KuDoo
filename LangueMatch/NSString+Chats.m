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

+(NSString *) lm_createGroupIdWithUsers:(NSArray *)userIds
{
    NSArray *orderedUsers = [userIds sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *id1 = (NSString *)obj1;
        NSString *id2 = (NSString *)obj2;
        
        if ([id1 compare:id2] < 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([id1 compare:id2] > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableString *groupId = [NSMutableString new];
    
    for (NSString *userId in orderedUsers) {
        [groupId appendString:userId];
    }
    
    return groupId;
}

+(NSString *) lm_parseError:(NSError *)error
{
    NSInteger errorCode = error.code;
    
    if (errorCode == kPFErrorConnectionFailed) return NSLocalizedString(@"Connection Failure, Please check your internet connection and try again", @"connection failed"); //100
    if (errorCode == kPFErrorObjectNotFound) return NSLocalizedString(@"No matches.", @"object not found"); //101
    if (errorCode == kPFErrorObjectTooLarge) return NSLocalizedString(@"Object is too large", @"object not found"); //116
    if (errorCode == kPFErrorOperationForbidden) return NSLocalizedString(@"Operation foribidden", @"operation forbidden"); //119
    if (errorCode == kPFErrorInvalidNestedKey) return NSLocalizedString(@"Values may not include '$' of '.'", @"invalid nested key"); //121
    if (errorCode == kPFErrorTimeout) return NSLocalizedString(@"The request timed out, Please check your internet connection", @"timeout"); //124
    if (errorCode == kPFErrorInvalidEmailAddress) return NSLocalizedString(@"Invalid Email Address", @"invalidEmailAddress"); // 125
    if (errorCode == kPFErrorDuplicateValue) return NSLocalizedString(@"Duplicate Value", @"duplicate value"); // 137
    if (errorCode == kPFErrorInvalidImageData) return NSLocalizedString(@"Invalid Image Data", @"invalid image data"); // 150
    if (errorCode == kPFErrorFileDeleteFailure) return NSLocalizedString(@"File Delete Failed", @"file delete failure"); // 153
    if (errorCode == kPFErrorRequestLimitExceeded) return NSLocalizedString(@"Request Limit Exceeded", @"request limit exceeded"); // 155
    if (errorCode == kPFErrorUsernameMissing) return NSLocalizedString(@"Username Missing", @"username missing"); //200
    if (errorCode == kPFErrorUserPasswordMissing) return NSLocalizedString(@"Password is Missing", @"password missing"); //201
    if (errorCode == kPFErrorUsernameTaken) return NSLocalizedString(@"Sorry, That Username is already taken. Please try another", @"username taken"); // 202
    if (errorCode == kPFErrorUserEmailTaken) return NSLocalizedString(@"That Email is registered with another account", @"user email taken"); // 203
    if (errorCode == kPFErrorUserEmailMissing) return NSLocalizedString(@"Email Is Missing", @"user email missing"); // 204
    if (errorCode == kPFErrorUserWithEmailNotFound) return NSLocalizedString(@"Email Is Not Linked to any accounts", @"user with email not found"); //205
    if (errorCode == kPFErrorFacebookAccountAlreadyLinked) return NSLocalizedString(@"Facebook account is already linked", @"facebook account already linked"); //208
    if (errorCode == kPFErrorAccountAlreadyLinked) return NSLocalizedString(@"Account is already linked", @"account already linked"); //208
    if (errorCode == kPFErrorInvalidSessionToken) return NSLocalizedString(@"Invalid Session Token", @"invalid session token"); //209
    if (errorCode == kPFErrorFacebookIdMissing) return NSLocalizedString(@"Facebook Id Missing", @"FacebookIdMissing"); // 250
    
    return NSLocalizedString(@"Sorry but we seemed to be lost on this end! Please try again in a little bit", @"WeFuckedUp");
}

+(NSString *) lm_dateToString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *) lm_dateToStringShortDateAndTime:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    formatter.doesRelativeDateFormatting = YES;
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *) lm_dateToStringShortDateOnly:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *) lm_pathForFilename:(NSString *) filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

@end
