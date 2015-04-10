//
//  LMContactListViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContactListViewController.h"
#import "LMContacts.h"
#import "LMContactTableView.h"
#import "Utility.h"

@interface LMContactListViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentControl;

@property (strong, nonatomic) LMContacts *contactLists;
@property (strong, nonatomic) LMContactTableView *phoneBookContacts;
@property (strong, nonatomic) LMContactTableView *facebookContacts;

@end

@implementation LMContactListViewController

- (instancetype) init
{
    if (self = [super init]) {
        _contactLists = [[LMContacts alloc] init];
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"sample-1093-lightning-bolt-2.png"]];
        self.tabBarItem.title = @"Contacts";
        
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"PhoneBook", @"Facebook"]];
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = _segmentControl;
    
    self.phoneBookContacts = [[LMContactTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    self.phoneBookContacts.contactList = _contactLists.phoneBookContacts;
    
    self.facebookContacts = [[LMContactTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    self.facebookContacts.contactList = _contactLists.facebookContacts;
    
    for (UIView *view in @[_phoneBookContacts, _facebookContacts]) {
        [self.view addSubview:view];
    }
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showContactList];
}

-(void)segmentControlValueChanged:(UIControl *)event
{
    [self showContactList];
}

/* -- Present respective tableview. If facebook contact list is empty prompt user to link account with facebook -- */

-(void) showContactList
{
    NSInteger selectedSegment = _segmentControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [self.view bringSubviewToFront:_phoneBookContacts];
    } else {
        
        [self.view bringSubviewToFront:_facebookContacts];
        
        if (_facebookContacts.contactList.count == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your LanguMatch account is not currently linked with Facebook", @"Your LanguMatch account is not currently linked with Facebook")
                                                                message:NSLocalizedString(@"Would you like to link them?", @"Would you like to link them?")
                                                               delegate:self
                                                      cancelButtonTitle:@"Na its cool"
                                                      otherButtonTitles:@"OMG Yes!", nil];
            
            [alertView show];
        }
    }
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark - Application Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
