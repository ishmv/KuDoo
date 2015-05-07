//
//  LMFriendRequestModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/6/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface LMFriendRequestModel : NSObject

@property (strong, nonatomic, readonly) NSArray *friendRequests;

-(void) addFriendRequestsObject:(PFObject *)object;

@end
