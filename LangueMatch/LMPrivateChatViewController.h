//
//  LMPrivateChatViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatViewController.h"

@interface LMPrivateChatViewController : LMChatViewController

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId fromRequest:(NSDictionary *)request;

@end
