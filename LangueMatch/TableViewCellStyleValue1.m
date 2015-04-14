//
//  TableViewCellStyleValue2.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/13/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "TableViewCellStyleValue1.h"

@implementation TableViewCellStyleValue1

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
