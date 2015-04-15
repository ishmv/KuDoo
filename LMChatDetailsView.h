/*
 
Class handles setting group chat details
 
*/


#import <UIKit/UIKit.h>

@protocol LMChatDetailsViewDelegate <NSObject>

-(void)chatImageViewTapped:(UIImageView *)imageView;

@end

@interface LMChatDetailsView : UIView

@property (strong, nonatomic) UITextField *chatTitle;
@property (strong, nonatomic) UIImageView *chatImageView;
@property (weak, nonatomic) id <LMChatDetailsViewDelegate> delegate;

@end
