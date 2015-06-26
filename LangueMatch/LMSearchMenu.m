//
//  LMSearchMenu.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/20/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSearchMenu.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"
#import "LMLanguageOptionsTableView.h"

@interface LMSearchMenu ()

@property (nonatomic, strong) NSArray *searchOptions;
@property (nonatomic, strong) LMLanguageOptionsTableView *languageOptions;

@end

@implementation LMSearchMenu

static NSString *const reuseIdentifer = @"reuseIdentifier";

-(instancetype) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        
        _searchOptions = @[NSLocalizedString(@"Online", @"Online"), NSLocalizedString(@"Username", @"Username"), NSLocalizedString(@"Location", @"Location"), NSLocalizedString(@"Fluent", @"Fluent"), NSLocalizedString(@"Learning", @"Learning"), NSLocalizedString(@"Pair Me", @"Pair Me")];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifer];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchOptions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    }
    
    switch (indexPath.row) {
        case 3:
        case 4:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor lm_orangeColor];
    cell.textLabel.font = [UIFont lm_robotoLightMessage];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = self.searchOptions[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 69)];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate LMSearchMenu:self didSelectOption:indexPath.row];
}


@end
