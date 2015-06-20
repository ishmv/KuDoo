//
//  UIButton+TapAnimation.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/18/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "UIButton+TapAnimation.h"

@implementation UIButton (TapAnimation)

+(void) lm_animateButtonPush:(UIButton *)sender
{
    sender.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.transform = CGAffineTransformIdentity;
    } completion:nil
     ];
}

@end
