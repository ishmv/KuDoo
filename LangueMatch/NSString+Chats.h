//
//  NSString+Chats.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/4/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Chats)

+(NSString *) lm_createGroupIdWithUsers:(NSArray *)userIds;
+(NSString *) lm_parseError:(NSError *)error;
+(NSString *) lm_dateToString:(NSDate *)date;
+(NSString *) lm_dateToStringShort:(NSDate *)date;
+(NSString *) lm_pathForFilename:(NSString *) filename;

@end
