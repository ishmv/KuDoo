//
//  LMPeoplePicker.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/22/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMPeoplePicker;

@protocol LMPeoplePickerDelegate <NSObject>

@optional

-(void) LMPeoplePicker:(LMPeoplePicker *)picker didFinishPickingPeople:(NSArray *)people;

@end

@interface LMPeoplePicker : UITableViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

-(instancetype) initWithContacts:(NSOrderedSet *)contacts;

@property (weak, nonatomic) id <LMPeoplePickerDelegate> delegate;

@end
