//
//  TableViewController.h
//  simplechat
//
//  Created by Travis Buttaccio on 5/30/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

@import UIKit;

@interface ForumTableViewController : UITableViewController

-(instancetype) initWithFirebaseAddress:(NSString *)path;

@property (nonatomic, copy, readonly) NSString *firebasePath;

@end
