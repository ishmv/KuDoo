//
//  LMCollectionViewCell.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMCollectionViewCell.h"

@implementation LMCollectionViewCell

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

@end
