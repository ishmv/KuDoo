#import <UIKit/UIKit.h>

@protocol LMSignUpViewControllerDelegate <NSObject>

-(void)userSuccessfullySignedUp;

@end

@interface LMSignUpViewController : UIViewController

@property (nonatomic, weak) id <LMSignUpViewControllerDelegate> delegate;

@end
