//
//  LMSlideView.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/18/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LMSlideViewDelegate <NSObject>

-(void) viewSwipedWithGestureRecognizer:(UIGestureRecognizer *)gesture;

@end

@interface LMSlideView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection swipeDirection;
@property (nonatomic, weak) id <LMSlideViewDelegate> delegate;

@end
