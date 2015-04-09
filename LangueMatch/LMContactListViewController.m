//
//  LMContactListViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContactListViewController.h"
#import "LMContacts.h"
#import "LMPhoneBookTableViewController.h"

@interface LMContactListViewController ()

@property (strong, nonatomic) LMContacts *contactLists;
@property (strong, nonatomic) LMPhoneBookTableViewController *phoneBookViewController;

@end

@implementation LMContactListViewController

- (instancetype) init
{
    if (self = [super init]) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-1093-lightning-bolt-2.png"]];
        self.tabBarItem.title = @"Contacts";
        
        _contactLists = [[LMContacts alloc] init];
        _phoneBookViewController = [[LMPhoneBookTableViewController alloc] initWithContactList:_contactLists.phoneBookContacts];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setViewControllers:@[_phoneBookViewController]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_phoneBookViewController.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
