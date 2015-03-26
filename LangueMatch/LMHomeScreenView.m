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
static CGFloat cellWidth = 150;

+(void)load
{
    titleArray = [NSArray arrayWithObjects:@"Messages", @"Friends", @"My Profile", @"Talk", @"Discussion Rooms", @"Schedule", nil];
    
    buttonImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sample-401-globe.png"],
                    [UIImage imageNamed:@"sample-307-atom.png"],
                    [UIImage imageNamed:@"sample-1116-slayer-hand.png"],
                    [UIImage imageNamed:@"sample-976-bow-and-arrow.png"],
                    [UIImage imageNamed:@"sample-920-handbag.png"],
                    [UIImage imageNamed:@"sample-1012-sticky-note.png"], nil];
    
    buttonColors = [NSArray arrayWithObjects:[UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0],
                    [UIColor colorWithRed:241/255.0 green:196/255.0 blue:15/255.0 alpha:1.0],
                    [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1.0],
                    [UIColor colorWithRed:231/255.0 green:76/255.0 blue:60/255.0 alpha:1.0],
                    [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182/255.0 alpha:1.0],
                    [UIColor colorWithRed:44/255.0 green:62/255.0 blue:80/255.0 alpha:1.0], nil];
}

-(instancetype)init
{
    if (self = [super init]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellWidth, cellWidth);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
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
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_collectionView]-20-|"
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
    
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 2;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMHomeScreenViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    int itemNumber;
    
    if (indexPath.section == 0 && indexPath.item == 0) {
        itemNumber = 0;
    } else if (indexPath.section == 0 && indexPath.item == 1) {
        itemNumber = 1;
    } else if (indexPath.section == 1 && indexPath.item == 0) {
        itemNumber = 2;
    } else if (indexPath.section == 1 && indexPath.item == 1) {
        itemNumber = 3;
    } else if (indexPath.section == 2 && indexPath.item == 0) {
        itemNumber = 4;
    } else if (indexPath.section == 2 && indexPath.item == 1){
        itemNumber = 5;
    }
    
    cell.buttonColor = [UIColor clearColor];     //buttonColors[itemNumber];
    cell.buttonTitle = titleArray[itemNumber];
    cell.buttonImage = buttonImages[itemNumber];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = self.collectionView.frame.size.width / cellWidth;
    NSInteger edgeInsets = (self.collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells);
    
    return UIEdgeInsetsMake(10, edgeInsets, 10, edgeInsets);
}



@end
