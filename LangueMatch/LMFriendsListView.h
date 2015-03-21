#import <UIKit/UIKit.h>

@protocol LMFriendsListViewDelegate <UITableViewDataSource, UITableViewDelegate>

@optional

@end

@interface LMFriendsListView : UIView

@property (nonatomic, weak) id <LMFriendsListViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;

@end
