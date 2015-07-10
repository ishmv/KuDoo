//
//  LMUserProfileTests.m
//  KuDoo
//
//  Created by Travis Buttaccio on 7/9/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMUserProfileViewController.h"
#import "AppConstant.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Parse/Parse.h>

@interface LMUserProfileTests : XCTestCase

@property (strong, nonatomic) LMUserProfileViewController *profileVC;
@property (strong, nonatomic) PFUser *user;

@end

@implementation LMUserProfileTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _user = [PFUser new];
    _profileVC = [[LMUserProfileViewController alloc] initWithUser:_user];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
