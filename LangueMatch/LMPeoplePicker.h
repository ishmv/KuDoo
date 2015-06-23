//
//  LMPeoplePicker.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/22/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMPeoplePicker : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

-(instancetype) initWithContacts:(NSOrderedSet *)contacts;

@end