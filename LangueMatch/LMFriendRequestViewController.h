//
//  LMFriendRequestViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/6/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@protocol LMFriendRequestViewControllerDelegate <NSObject>

-(void) newFriendRequestCount:(NSNumber *)requests;
-(void) addUserToFriendList:(PFUser *)user;

@end

@interface LMFriendRequestViewController : UITableViewController

@property (nonatomic, weak) id <LMFriendRequestViewControllerDelegate> delegate;

@end
