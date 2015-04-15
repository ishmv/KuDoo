//
//  LMChatDetailsViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMCompletedChatDetails)(NSDictionary *chatDetails);

@interface LMChatDetailsViewController : UIViewController

-(instancetype)initWithCompletion:(LMCompletedChatDetails)completion;

@end
