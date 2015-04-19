//
//  LMMessage.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Parse/Parse.h>

@class LMUser;

@interface LMMessage : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) LMUser *sender;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) UIImage *image;

@end
