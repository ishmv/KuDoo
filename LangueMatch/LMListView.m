#import "LMListView.h"

@interface LMListView()

@end

@implementation LMListView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        
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

-(void)setDelegate:(id<LMListViewDelegate>)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}


@end