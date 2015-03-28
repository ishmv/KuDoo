//
//  ViewController.m
//  PageViewDemo
//
//  Created by Travis Buttaccio on 3/25/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMLoginWalkthrough.h"
#import "LMLoginViewController.h"

@interface LMLoginWalkthrough () <UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *langueMatchLabel;

@end

@implementation LMLoginWalkthrough

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    [login setTitle:@"Login" forState:UIControlStateNormal];
    login.frame = CGRectMake(50, 150, 150, 150);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [self.view bringSubviewToFront:self.registerButton];
    [self.view bringSubviewToFront:self.loginButton];
    [self.view bringSubviewToFront:self.langueMatchLabel];
    
    [self.pageViewController didMoveToParentViewController:self];
}

static NSArray *pictures;
static NSArray *titles;

+(void)load
{
    pictures = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
    titles =  @[@"Learn a language by talking with native speakers around the world", @"Signup with your Facebook account", @"Practice your communication at any time of the day", @"... And absolutely no cost \n Get Started Below"];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{

    NSInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [titles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [titles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([titles count] == 0) || (index >= [titles count])) {
        return nil;
    }
    

    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = pictures[index];
    pageContentViewController.titleText = titles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

@end
