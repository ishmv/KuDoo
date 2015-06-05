//
//  SelectLanguages.h
//  simplechat
//
//  Created by Travis Buttaccio on 6/2/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LMGlobalVariables.h"
#import "AppConstant.h"
#import "UIFont+ApplicationFonts.h"
#import "UIColor+applicationColors.h"

@interface SelectLanguages : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker1;
@property (weak, nonatomic) IBOutlet UIPickerView *picker2;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end
