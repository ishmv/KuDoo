//
//  CALayer+BackgroundLayers.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "CALayer+BackgroundLayers.h"
#import "UIColor+applicationColors.h"

@implementation CALayer (BackgroundLayers)

+(CALayer *) lm_universalBackgroundColor
{
    CALayer *colorLayer = ({
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.locations = @[@(0.5), @(0.8)];
        layer.colors = @[(id)[UIColor lm_tealBlueColor].CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.7f] .CGColor, (id)[[UIColor lm_tealBlueColor] colorWithAlphaComponent:0.4f].CGColor];
        layer.startPoint = CGPointMake(0.3, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer;
    });
    
    return colorLayer;
}

+ (CALayer *) lm_wetAsphaltWithOpacityBackgroundLayer
{
    CALayer *layer = ({
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor lm_wetAsphaltColor].CGColor;
        layer.opacity = 0.95f;
        layer;
    });
    
    return layer;
}

+ (CALayer *) lm_spaceImageBackgroundLayer
{
    CALayer *imageLayer = ({
        CALayer *layer = [CALayer layer];
        layer.contents = (id)[UIImage imageNamed:@"spacePicture2.jpg"].CGImage;
        layer.contentsGravity = kCAGravityCenter;
        layer;
    });
    
    return imageLayer;
}

@end