#import <UIKit/UIKit.h>

@protocol LMLoginViewControllerDelegate <NSObject>

-(void)userSuccessfullyLoggedIn;

@end

@interface LMLoginViewController : UIViewController

@property (nonatomic, weak) id <LMLoginViewControllerDelegate> delegate;

@end
