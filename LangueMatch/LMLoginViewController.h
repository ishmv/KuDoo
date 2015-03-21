#import <UIKit/UIKit.h>

@protocol LMLoginViewControllerDelegate <NSObject>

-(void) userPressedLoginButton;

@end

@interface LMLoginViewController : UIViewController

@property (nonatomic, weak) id <LMLoginViewControllerDelegate> delegate;

@end
