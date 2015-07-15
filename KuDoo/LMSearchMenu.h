//
//  LMSearchMenu.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/20/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMSearchMenu;

@protocol LMSearchMenuDelegate <NSObject>

-(void) LMSearchMenu:(LMSearchMenu *)searchMenu didSelectOption:(NSInteger)selection;

@end

@interface LMSearchMenu : UITableViewController

@property (weak, nonatomic) id <LMSearchMenuDelegate> delegate;

@end
