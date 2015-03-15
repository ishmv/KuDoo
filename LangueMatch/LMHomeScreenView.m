#import "LMHomeScreenView.h"
#import "LMHomeScreenViewControllerCell.h"

@interface LMHomeScreenView() <UICollectionViewDataSource>


@end

@implementation LMHomeScreenView

#pragma mark - Constants
static NSString * const reuseIdentifier = @"Cell";
static NSArray *titleArray;
static NSArray *buttonColors;
static NSArray *buttonImages;
static CGFloat cellWidth = 100;

+(void)load
{
    titleArray = [NSArray arrayWithObjects:@"Chat", @"Talk", @"Friends", nil];
    buttonImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sample-401-globe.png"], [UIImage imageNamed:@"sample-307-atom.png"], [UIImage imageNamed:@"sample-1116-slayer-hand.png"], nil];
    buttonColors = [NSArray arrayWithObjects:[UIColor colorWithHue:0.5 saturation:0.5 brightness:0.5 alpha:0.5], [UIColor colorWithHue:0.7 saturation:0.5 brightness:0.5 alpha:0.5], [UIColor colorWithHue:0.3 saturation:0.5 brightness:0.5 alpha:0.5], nil];
}


-(instancetype)init
{
    if (self = [super init]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellWidth, cellWidth);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.collectionView.dataSource = self;
        
        [self.collectionView registerClass:[LMHomeScreenViewControllerCell class] forCellWithReuseIdentifier:reuseIdentifier];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.collectionView];
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_collectionView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_collectionView]-8-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]-15-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
}

#pragma mark - CollectionView Flow Layout Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMHomeScreenViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.buttonColor = buttonColors[indexPath.item];
    cell.buttonTitle = titleArray[indexPath.item];
    cell.buttonImage = buttonImages[indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = self.collectionView.frame.size.width / cellWidth;
    NSInteger edgeInsets = (self.collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells);
    
    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

@end
