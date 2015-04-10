//
//  LMContactTableView.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/9/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMContactTableView.h"
#import "LMPerson.h"

@interface LMContactTableView() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation LMContactTableView

static NSString *const reuseIdentifier = @"cell";


-(void)setContactList:(NSArray *)contactList
{
    _contactList = contactList;

    self.delegate = self;
    self.dataSource = self;
    
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contactList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    LMPerson *person = _contactList[indexPath.row];
    
    [cell.textLabel setText:person.fullName];
    [cell.detailTextLabel setText:person.homeEmail];
    
    cell.imageView.contentMode = UIViewContentModeScaleToFill;
    
    if (person.image != nil) {
        cell.imageView.image = person.image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"empty_profile.png"];
    }
    
    return cell;
}

@end
