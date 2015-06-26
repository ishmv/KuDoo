//
//  LMChatDetails.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/24/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatDetails.h"
#import "Utility.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"
#import "LMCollectionViewCell.h"
#import "ParseConnection.h"
#import "AppConstant.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

//Just for checking - take out
#import "NSArray+LanguageOptions.h"

@interface LMChatDetails () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *details;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSOrderedSet *allMessages;
@property (nonatomic, strong) NSArray *chatMembers;

@end

@implementation LMChatDetails

static NSString *const reuseIdentifier = @"reuseIdentifier";

-(instancetype) initWithDetails:(NSDictionary *)details
{
    if (self = [super init]) {
        _details = details;
        _allMessages = details[@"messages"];
        
        if ([details[@"member"] isKindOfClass:[NSArray class]]) [self getChatImage:details[@"image"]];
        else [self getUserThumbnail:details[@"member"]];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.image = details[@"chatImage"];
        
        _images = [[NSArray lm_countryFlagImages] copy];
        
        for (UIView *view in @[_collectionView, _tableView, _imageView]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:view];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lm_tealColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont lm_noteWorthyLargeBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:NSLocalizedString(@"Chat Details", @"Chat Details")];
    [self.navigationItem setTitleView:titleLabel];
    
    self.view.backgroundColor = [UIColor lm_beigeColor];
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor lm_beigeColor];
    
    [self.collectionView registerClass:[LMCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat topBarHeight = 64.0f;
    
    CONSTRAIN_HEIGHT(_imageView, 100);
    CONSTRAIN_WIDTH(_imageView, 100);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _imageView, topBarHeight + 8);
    ALIGN_VIEW_LEFT_CONSTANT(self.view, _imageView, 8);
    
    CONSTRAIN_WIDTH(_tableView, viewWidth - 116);
    CONSTRAIN_HEIGHT(_tableView, 150);
    ALIGN_VIEW_LEFT_CONSTANT(self.view, _tableView, 116);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _tableView, topBarHeight + 8);
    
    CONSTRAIN_HEIGHT(_collectionView, 300);
    CONSTRAIN_WIDTH(_collectionView, viewWidth);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _collectionView, topBarHeight + 174);
    CENTER_VIEW_H(self.view, _collectionView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Date";
            break;
        case 1:
            cell.textLabel.text = @"Inception";
            break;
        case 2:
            cell.textLabel.text = @"People";
            break;
        default:
            break;
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.details.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.details[@"title"];
    }
    
    return @"";
}

#pragma mark - Collection View Data Source

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
    return CGSizeMake(90, 90);
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
    photoBrowser.displayCounterLabel = YES;
    
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

#pragma mark - Private Methods
-(void) getUserThumbnail:(NSString *)userId
{
    if (!_imageView.image) {
        
        [ParseConnection searchForUserIds:@[userId] withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            
            PFUser *user = [objects firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                ESTABLISH_WEAK_SELF;
                
                PFFile *imageFile = user[PF_USER_THUMBNAIL];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    ESTABLISH_STRONG_SELF;
                    
                    UIImage *chatImage = [UIImage imageWithData:data];
                    strongSelf.imageView.image = chatImage;
                }];
            });
        }];
    }
}

-(void) getChatImage:(NSString *)urlString
{
    if (!_imageView.image) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            ESTABLISH_WEAK_SELF;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ESTABLISH_STRONG_SELF;
                UIImage *chatImage = (UIImage *)responseObject;
                strongSelf.imageView.image = chatImage;
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to retreive chat image");
        }];
        
        [[NSOperationQueue mainQueue] addOperation:operation];
        
    }
}

@end
