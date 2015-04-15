//
//  ChatView.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/18/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class PFObject;

//Implement if chat is random
@protocol LMRandomChatViewDelegate <NSObject>

-(void)endedRandom:(PFObject *)chat;

@end

@interface ChatView : JSQMessagesViewController

-(instancetype) initWithChat:(PFObject *)chat;

@property (nonatomic, weak) id <LMRandomChatViewDelegate> delegate;


@end
