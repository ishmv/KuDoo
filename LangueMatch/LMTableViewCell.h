//
//  LMTableViewCell.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *cellImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *accessoryLabel;

@end
