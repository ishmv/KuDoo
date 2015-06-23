//
//  LMPeoplePicker.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/22/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMPeoplePicker.h"
#import "ParseConnection.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "UITextField+LMTextFields.h"
#import "UIColor+applicationColors.h"
#import "OnlineUsersViewController.h"
//#import "UIFont+ApplicationFonts.h"

@interface LMPeoplePicker ()

@property (strong, nonatomic) NSMutableArray *chatParticipants;
@property (strong, nonatomic) NSOrderedSet *contacts;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *chatName;

@property (strong, nonatomic) UIViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation LMPeoplePicker

static NSString *const reuseIdentifier = @"reuseIdentifier";
static NSInteger const MAX_CHAT_TITLE_LENGTH = 15;

#pragma mark - View Controller Life Cycle

-(instancetype) initWithContacts:(NSOrderedSet *)contacts
{
    if (self = [super init]) {
        _contacts = contacts;

        _searchResultsController = [[UIViewController alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        
        _chatName = [UITextField lm_defaultTextFieldWithPlaceholder:NSLocalizedString(@"Chat Name", @"Chat Name")];
        _chatName.delegate = self;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self addChildViewController:_searchResultsController];
        
        for (UIView *view in @[_chatName, _tableView]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:view];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_noteWorthyLargeBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"New Chat", @"Chat")];
    [self.navigationItem setTitleView:titleLabel];
    
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search username", @"Search username");
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.barTintColor = [UIColor lm_beigeColor];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;

    UIBarButtonItem *startChatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = startChatButton;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    CGFloat topBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame) + 20;
    
    CONSTRAIN_WIDTH(_chatName, viewWidth - 100);
    CONSTRAIN_HEIGHT(_chatName, 44);
    CENTER_VIEW_H(self.view, _chatName);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _chatName, topBarHeight + 12);
    
//    CONSTRAIN_WIDTH(_searchResultsController.view, viewWidth);
//    CONSTRAIN_HEIGHT(_searchResultsController.view, viewHeight - topBarHeight - 60);
//    ALIGN_VIEW_TOP_CONSTANT(self.view, _searchResultsController.view, topBarHeight + 104);
    
    CONSTRAIN_WIDTH(_tableView, viewWidth);
    CONSTRAIN_HEIGHT(_tableView, viewHeight - 44.0f);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _tableView, topBarHeight + 60);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            PFUser *user = self.searchResults[indexPath.row];
            cell.textLabel.text = user[PF_USER_DISPLAYNAME];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
            break;
        case 1:
        {
            PFUser *user = self.searchResults[indexPath.row];
            cell.textLabel.text = user[PF_USER_DISPLAYNAME];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAX_CHAT_TITLE_LENGTH || returnKey;
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [ParseConnection searchForUsername:searchBar.text withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
        self.searchResults = objects;
        [self.tableView reloadData];
    }];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark - Search Controller Delegate

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
