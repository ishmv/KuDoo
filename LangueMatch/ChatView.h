//
//  ChatView.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/18/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class PFObject;

@interface ChatView : JSQMessagesViewController

-(instancetype) initWithGroupId:(NSString *)groupId;

-(instancetype) initWithChat:(PFObject *)chat;

@end
