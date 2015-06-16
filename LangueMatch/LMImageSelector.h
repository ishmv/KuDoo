//
//  LMImageSelector.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMImageSelector : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

-(instancetype) initWithImages:(NSArray *)images;

@end
