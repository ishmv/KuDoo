//
//  LMFriendRequestUserProfileViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/6/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMUserProfileViewController.h"

@class PFObject;

@protocol LMFriendRequestUserProfileViewControllerDelegate <NSObject>

-(void) userAcceptedFriendRequest:(PFObject *)request;
-(void) userDeclinedFriendRequest:(PFObject *)request;

@end

@interface LMFriendRequestUserProfileViewController : LMUserProfileViewController

-(instancetype) initWithRequest:(PFObject *)request;

@property (strong, nonatomic) id <LMFriendRequestUserProfileViewControllerDelegate> delegate;

@end
