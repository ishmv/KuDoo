//
//  LMFriendsModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

@interface LMFriendsModel : NSObject

@property (strong, nonatomic, readonly) NSArray *friendList;

-(void) addFriend:(PFUser *)user;

@end
