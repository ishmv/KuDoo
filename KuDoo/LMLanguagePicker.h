#import <UIKit/UIKit.h>

@class LMLanguagePicker;

typedef void (^LMLanguageSelectionBlock)(NSInteger idx);

@interface LMLanguagePicker : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

-(instancetype) initWithTitles:(NSArray *)titles images:(NSArray *)images andCompletion:(LMLanguageSelectionBlock)selection;

@property (copy, nonatomic) NSString *pickerTitle;
@property (copy, nonatomic) NSString *pickerFooter;

@property (strong, nonatomic, readonly) NSArray *titles;
@property (strong, nonatomic, readonly) NSArray *images;

// Default height is 60.0f
@property (nonatomic, assign) CGFloat rowHeight;

//Default is the superviews width - 100
@property (nonatomic, assign) CGFloat rowWidth;

@end