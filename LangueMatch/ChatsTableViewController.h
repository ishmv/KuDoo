//
//  ChatsTableViewController.h
//  friendChat
//
//  Created by Travis Buttaccio on 6/1/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMPrivateChatViewController.h"

#import <UIKit/UIKit.h>

@class FDataSnapshot;

@interface ChatsTableViewController : UITableViewController <LMChatViewControllerDelegate>

-(instancetype) initWithFirebaseAddress:(NSString *)path;

@property (nonatomic, copy, readonly) NSString *firebasePath;

-(void) updateChatsWithSnapshot:(FDataSnapshot *)snapshot;

-(NSDictionary *) lastSentMessages;

@end
