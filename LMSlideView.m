//
//  LMSlideView.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/18/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSlideView.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

@interface LMSlideView()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation LMSlideView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        
        self.label = ({
            UILabel *label = [UILabel new];
            label.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
            [label setTextColor:[UIColor clearColor]];
            [label setBackgroundColor:[UIColor lm_lightYellowColor]];
            label.userInteractionEnabled = YES;
            label;
        });
        
        self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(labelSwiped:)];
        [self addGestureRecognizer:self.swipeGesture];
        
        [self addSubview:self.label];
    }
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}

-(void)setLabelText:(NSString *)labelText
{
    _labelText = [labelText copy];
    
    NSDictionary *fontAttribute = @{NSFontAttributeName : [UIFont lm_noteWorthyMedium]};
    CGSize textSize = [labelText sizeWithAttributes:fontAttribute];
    CGSize labelSize = self.label.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(self.label.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGPoint center = CGPointMake(labelSize.width/2 - textSize.width/2, labelSize.height/2 - textSize.height/2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    
    [labelText drawAtPoint:center withAttributes:fontAttribute];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (__bridge id)(viewImage.CGImage);
    maskLayer.frame = self.label.frame;
    self.label.layer.mask = maskLayer;
}

-(void)setSwipeDirection:(UISwipeGestureRecognizerDirection)swipeDirection
{
    _swipeDirection = swipeDirection;
    self.swipeGesture.direction = swipeDirection;
    
    CALayer *slideLayer = [CALayer layer];
    slideLayer.backgroundColor = [UIColor whiteColor].CGColor;
    slideLayer.cornerRadius = 20;
    slideLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame)/2.5, 35);
    [self.layer insertSublayer:slideLayer below:self.label.layer];
    
    CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    slideAnimation.fromValue = @(-self.frame.size.width/2);
    slideAnimation.toValue = @(self.frame.size.width*2);
    slideAnimation.duration = 3;
    slideAnimation.repeatCount = 1e10;
    [slideLayer addAnimation:slideAnimation forKey:nil];
}


-(void) labelSwiped:(UIGestureRecognizer *)gesture
{
    [self.delegate viewSwipedWithGestureRecognizer:gesture];
}


@end
