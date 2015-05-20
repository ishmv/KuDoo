//
//  LMMessageFactory.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/19/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMMessageFactory.h"
#import "AppConstant.h"

#import <Parse/Parse.h>
#import <JSQMessages.h>

@implementation LMMessageFactory

+(PFObject *) createMessageType:(LMMessageType)type withDetails:(NSDictionary *)details
{
    return [PFObject new];
}

+(JSQMessage *) createJSQMessageFromLMMessage:(PFObject *)message
{
    JSQMessage *jsqMessage;
    return jsqMessage;
}


@end
