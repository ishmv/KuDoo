//
//  LMPrivateChatViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatViewController.h"

@interface LMPrivateChatViewController : LMChatViewController

/*
 
 Default initializer
 
 Chat info can include the following:
 
 required:
 @"groupId" - the groupId
 
 optional:
 @"title" - displayed at the top of the chat window
 @"date" - chats inception
 @"members" - an array of each PFUser object in the chat
 @"imageURL" - a URL to the chat image
 @"type" - single or group
 @"admin" - the person who started the chat
 
 */
-(instancetype) initWithFirebaseAddress:(NSString *)address andChatInfo:(NSDictionary *)info;

@property (strong, nonatomic) UIImage *chatImage;

@end
