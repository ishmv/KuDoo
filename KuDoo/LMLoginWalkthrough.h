//
//  LMWalkthrough.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/11/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface LMLoginWalkthrough : UIViewController

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
//@property (strong, nonatomic) NSArray *foregroundImages;

@end
