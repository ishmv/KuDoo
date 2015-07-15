//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Travis Buttaccio on 3/25/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "PageContentViewController.h"

#import "CALayer+BackgroundLayers.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.foregroundImageView.image = [UIImage imageNamed:self.foregroundImageFile];
    self.titleLabel.text = self.titleText;
    self.view.backgroundColor = [UIColor clearColor];
    
//    CALayer *layer = [CALayer lm_universalBackgroundColor];
//    layer.frame = self.view.frame;
//    [self.backgroundImageView.layer addSublayer:layer];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
    [pageControl setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    self.backgroundImageView.image = nil;
    self.foregroundImageView.image = nil;
}

@end
