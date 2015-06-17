//
//  LMLocationPicker.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/17/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLPlacemark, LMLocationPicker;

@protocol LMLocationPickerDelegate <NSObject>

-(void) locationPicker:(LMLocationPicker *)locationPicker didSelectLocation:(CLPlacemark *)placemark;

@end

@interface LMLocationPicker : UIViewController

@property (weak, nonatomic) id <LMLocationPickerDelegate> delegate;

@end
