//
//  LMMessageModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSQMessage, PFObject;

@interface LMMessageModel : NSObject

-(instancetype)initWithChat:(PFObject *)chat;

@property (strong, nonatomic, readonly) NSArray *chatMessages;

-(void) addChatMessagesObject:(PFObject *)message;

@end
