//
//  LMLocationPicker.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/17/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMLocationPicker.h"
#import "Utility.h"

@import MapKit;

@interface LMLocationPicker () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation LMLocationPicker

static NSString *const reuseIdentifer = @"reuseIdentifier";

-(instancetype) init{
    if (self = [super init]) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _mapView.delegate = self;
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        
        for (UIView *view in @[_mapView, _tableView]) {
            [self.view addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setBackBarButtonItem:cancelButton];
    
    self.searchBar.frame = self.navigationItem.titleView.frame;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search or enter an address", @"Address Search");
    [self.navigationItem setTitleView:self.searchBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CONSTRAIN_WIDTH(_mapView, viewWidth);
    CONSTRAIN_HEIGHT(_mapView, viewHeight/2.0);
    ALIGN_VIEW_TOP_CONSTANT(self.view, _mapView, 44);
    
    ALIGN_VIEW_TOP_CONSTANT(self.view, _tableView, viewHeight/2.0 + 44);
    CONSTRAIN_WIDTH(_tableView, viewWidth);
    CONSTRAIN_HEIGHT(_tableView, viewHeight - viewHeight/3.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DroppedPin"];
    
    annotationView.draggable = YES;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    return annotationView;
}

#pragma mark - UITextField Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_mapView removeAnnotations:[_mapView annotations]];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        self.searchResults = placemarks;
        
        CLPlacemark *firstResult = [placemarks firstObject];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:firstResult];
        [self.mapView addAnnotation:placemark];
        
        MKCoordinateRegion mapRegion;
        
        mapRegion.center = placemark.coordinate;
        mapRegion.span.latitudeDelta = 5.0;
        mapRegion.span.longitudeDelta = 5.0;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        [self.tableView reloadData];
    }];
    
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    }
    
    CLPlacemark *placemark = self.searchResults[indexPath.row];
    
    NSMutableString *locationString = [[NSMutableString alloc] init];
    
    if (placemark.locality.length > 0) {
        [locationString appendString:placemark.locality];
    }
    
    if (placemark.administrativeArea.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@" %@", placemark.administrativeArea]];
    }
    
    if (placemark.country.length > 0) {
        [locationString appendString:[NSString stringWithFormat:@" %@", placemark.country]];
    }
    
    cell.textLabel.text = locationString;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchResults.count != 0) {
        return NSLocalizedString(@"Select location to set", @"Select location to set");
    }
    
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate locationPicker:self didSelectLocation:self.searchResults[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Touch Handling

-(void) cancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
