//
//  LMAlertControllers.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^LMCompletedWithUsername)(NSString *username);
typedef void (^LMCompletedWithLanguageSelection)(NSInteger language);
typedef void (^LMCompletedWithSourceType)(NSInteger type);

@interface LMAlertControllers : NSObject

+(UIAlertController *) chooseLanguageAlertWithCompletionHandler:(LMCompletedWithLanguageSelection)completion;
+(UIAlertController *) changeUsernameAlertWithCompletion:(LMCompletedWithUsername)completion;
+(UIAlertController *) choosePictureSourceAlertWithCompletion:(LMCompletedWithSourceType)completion;

@end
