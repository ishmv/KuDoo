#import <UIKit/UIKit.h>

#import "LMLoginView.h"

@class LMLoginViewController;
@class PFUser;

@protocol LMLoginViewControllerDelegate <NSObject>

@optional

-(void) loginViewController:(LMLoginViewController *)viewController didLoginUser:(PFUser *)user;

@end

@interface LMLoginViewController : UIViewController <LMLoginViewDelegate>

@property (strong, nonatomic) LMLoginView *loginView;
@property (weak, nonatomic) id <LMLoginViewControllerDelegate> delegate;

@end
