//
//  LMUser.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/16/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Parse/Parse.h>

#import "AppConstant.h"

@interface LMUser : PFUser <PFSubclassing>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *learningLanguage;
@property (strong, nonatomic) NSString *fluentLanguage;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) PFFile *picture;

@end
