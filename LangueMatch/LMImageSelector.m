//
//  LMImageSelector.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMImageSelector.h"
#import "LMCollectionViewCell.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface LMImageSelector () <IDMPhotoBrowserDelegate>

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) UICollectionView *collectionView;

@end

static NSString *const kFirebaseAddress = @"https://langMatch.firebaseio.com";
static NSString *const reuseIdentifier = @"reuseIdentifier";

@implementation LMImageSelector

-(instancetype) initWithImages:(NSArray *)images
{
    if (self = [super init]) {
        _images = images;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_robotoRegularTitle]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Chat Wallpaper", @"chat wallpaper")];
    [self.navigationItem setTitleView:titleLabel];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.view.frame) - 10, CGRectGetHeight(self.view.frame)-5) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor lm_beigeColor];
    [self.collectionView registerClass:[LMCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Data Source

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = self.images[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat itemWidth = (viewWidth - 20)/3.0;
    CGFloat itemHeight = (itemWidth * 16)/9.0;
    
    return CGSizeMake(itemWidth, itemHeight);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *photos = [IDMPhoto photosWithImages:self.images];
    IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    photoBrowser.actionButtonTitles = @[@"Cancel", @"Set"];
    photoBrowser.displayCounterLabel = YES;
    photoBrowser.delegate = self;
    
    [photoBrowser setInitialPageIndex:indexPath.item];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - IDMPhotoBrowserDelegate

-(void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex
{
    switch (buttonIndex) {
        case 0:
            [photoBrowser dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithInteger:photoIndex]];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"Chat_Wallpaper_Index"];
            [photoBrowser dismissViewControllerAnimated:YES completion:nil];
        }
        default:
            break;
    }
}

@end
