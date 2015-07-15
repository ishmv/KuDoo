//
//  CALayer+BackgroundLayers.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (BackgroundLayers)

+ (CALayer *) lm_universalBackgroundColor;
+ (CALayer *) lm_spaceImageBackgroundLayer;
+ (CALayer *) lm_wetAsphaltWithOpacityBackgroundLayer;

@end
