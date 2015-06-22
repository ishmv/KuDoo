//
//  LMLanguageOptionsTableView.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/21/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMLanguageOptionsTableView;

@protocol LMLanguageOptionsTableViewDelegate <NSObject>

-(void) LMLanguageOptionsTableView:(LMLanguageOptionsTableView *)tableView didSelectLanguage:(NSInteger)index;

@end

@interface LMLanguageOptionsTableView : UITableViewController

@property (weak, nonatomic) id <LMLanguageOptionsTableViewDelegate> delegate;

@end
