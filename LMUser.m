//
//  LMUser.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMUser.h"

#import <Parse/PFObject+Subclass.h>

@implementation LMUser

@dynamic username;
@dynamic learningLanguage;
@dynamic fluentLanguage;
@dynamic friends;
@dynamic objectId;
@dynamic picture;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"LMUser";
}

@end
