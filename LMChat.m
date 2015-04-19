//
//  LMChat.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChat.h"
#import "LMMessage.h"

#import <Parse/PFObject+Subclass.h>

@implementation LMChat

@dynamic members;
@dynamic lastMessage;
@dynamic groupId;
@dynamic picture;
@dynamic title;
@dynamic messages;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"LMChat";
}

@end
