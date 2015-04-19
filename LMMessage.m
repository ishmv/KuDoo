//
//  LMMessage.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMMessage.h"

#import <Parse/PFObject+Subclass.h>

@interface LMMessage()

@end

@implementation LMMessage

@dynamic text;
@dynamic groupId;
@dynamic sender;
@dynamic image;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"LMMessage";
}

@end
