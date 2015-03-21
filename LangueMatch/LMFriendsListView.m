#import "LMFriendsListView.h"

@interface LMFriendsListView()

@end

@implementation LMFriendsListView

-(instancetype) init
{
    if (self = [super init]) {
        self.tableView = [[UITableView alloc] init];
    
        for (UIView *view in @[self.tableView]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_tableView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_tableView]-|"
                                                                options:kNilOptions
                                                                metrics:nil
                                                                  views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:viewDictionary]];
}

-(void)setDelegate:(id<LMFriendsListViewDelegate>)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}


@end
