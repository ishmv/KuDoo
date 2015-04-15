#import <UIKit/UIKit.h>

@protocol LMListViewDelegate <UITableViewDataSource, UITableViewDelegate>

@optional

@end

@interface LMListView : UIView

@property (nonatomic, weak) id <LMListViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;

@end
