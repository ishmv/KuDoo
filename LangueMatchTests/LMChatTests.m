//
//  LMChatTests.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Firebase/Firebase.h>

#import "LMChatViewModel.h"
#import "LMChatViewController.h"
#import "AppConstant.h"

@interface LMChatTests : XCTestCase

@property (strong, nonatomic) FDataSnapshot *snapshot;

@end

@implementation LMChatTests

- (void)setUp {
    [super setUp];

    //Figure out a way to mock FDataSnapshot
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testChatViewModelSetsTypingLabelCorrectly
{
    NSString *userOneId = @"xpP4c629he";
    
    id chatViewMock = OCMClassMock([LMChatViewController class]);
    
    OCMStub([chatViewMock senderId]).andReturn(userOneId);
    
    LMChatViewModel *viewModel = [[LMChatViewModel alloc] initWithViewController:chatViewMock];
    
    NSString *typingLabel = [viewModel updateTypingLabelWithSnapshot:_snapshot];
    
    
    XCTAssertTrue([typingLabel isEqualToString:userOneId]);

    [chatViewMock stopMocking];
}



@end
