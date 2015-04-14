//
//  LMChatsModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/13/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface LMChatsModel : NSObject

@property (strong, nonatomic, readonly) NSArray *chatList;

-(void) deleteChat:(PFObject *)chat;

@end
