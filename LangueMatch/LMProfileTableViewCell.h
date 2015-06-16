//
//  LMProfileTableViewCell.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMProfileTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *cellImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *accessoryLabel;

@property (nonatomic, assign) CGFloat imageWidth;

@end
