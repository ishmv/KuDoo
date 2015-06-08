//
//  NSString+Chats.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/4/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Chats)

+(NSString *) lm_createGroupIdWithUsers:(NSArray *)users;
+(NSString *) lm_parseError:(NSError *)error;

@end
