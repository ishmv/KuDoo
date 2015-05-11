//
//  DetailViewController.h
//  LMAddressBook
//
//  Created by Travis Buttaccio on 5/10/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMContactDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *contactDetails;

@property (weak, nonatomic) IBOutlet UILabel *labelContactName;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UITableView *contactDetailsTableView;

@end

