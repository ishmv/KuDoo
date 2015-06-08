//
//  LMChatViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import <JSQMessagesViewController/JSQMessages.h>

@class Firebase;

@interface LMChatViewController : JSQMessagesViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/*
 
 Default initializer. Address will be used to create a firebase where the chat informatioon (users, messages, etc..) is stored.
 Using NSObject default initalizer will raise an exception;
 
*/
-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId;

/*

 The firebase associated with the chat

*/
@property (strong, readonly, nonatomic) NSString *firebaseAddress;

/*

 The groupId associated with the chat
 
*/
@property (strong, readonly, nonatomic) NSString *groupId;

/*

Setting value to yes will save messages to disk before chat view disappears. Default value is NO;
 
*/
@property (nonatomic, assign) BOOL archiveMessages;

@end
