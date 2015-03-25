//
//  LMUser.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 3/24/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


@interface LMUser : NSObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * desiredLanguage;
@property (nonatomic, retain) NSString * fluentLanguage;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) UIImage *picture;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;

@end
