//
//  NSDate+Chats.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "NSDate+Chats.h"

@implementation NSDate (Chats)

+(NSDate *) lm_stringToDate:(NSString *)string;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:string];
    
    return date;
}

+(NSDate *) lm_stringToDateRelative:(NSString *)string;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    formatter.doesRelativeDateFormatting = YES;
    NSDate *date = [formatter dateFromString:string];
    
    return date;
}

@end
