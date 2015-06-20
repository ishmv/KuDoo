//
//  LMUserViewModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFUser;

@interface LMUserViewModel : NSObject

-(instancetype) initWithUser:(PFUser *)user;
-(void) reloadData;

@property(strong, nonatomic, readonly) PFUser *user;

@property(copy, nonatomic, readonly) NSString *fluentLanguageString;
@property(copy, nonatomic, readonly) NSString *desiredLanguageString;
@property(copy, nonatomic, readonly) NSString *bioString;
@property(copy, nonatomic, readonly) NSString *locationString;
@property(copy, nonatomic, readonly) NSString *memberSinceString;

@property(strong, nonatomic, readonly) UIImage *fluentImage;
@property(strong, nonatomic, readonly) UIImage *desiredImage;
@property(strong, nonatomic, readonly) UIImage *backgroundPicture;
@property(strong, nonatomic, readonly) UIImage *profilePicture;

@end
