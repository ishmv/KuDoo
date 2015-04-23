//
//  LMChat.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Parse/Parse.h>

@class LMMessage;

@interface LMChat : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) PFFile *picture;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) LMMessage *lastMessage;

@end
