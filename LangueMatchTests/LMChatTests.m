//
//  LMChatTests.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/15/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>

#import "LMChatViewController.h"
#import "AppConstant.h"
#import "LMUser.h"
#import "LMMessage.h"
#import "LMChat.h"
#import "LMChatFactory.h"

@interface LMChatTests : XCTestCase

@property (strong, nonatomic) LMUser *user1;
@property (strong, nonatomic) LMUser *user2;
@property (strong, nonatomic) LMMessage *message1;
@property (strong, nonatomic) LMChat *chat;
@property (strong, nonatomic) LMChatFactory *chatFactory;

@end

@implementation LMChatTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _user1 = [LMUser object];
    _user2 = [LMUser object];
    
    _user1.username = @"Jeff";
    _user2.username = @"Dan";
    
    _user1.objectId = @"4283dTXhg6";
    _user2.objectId = @"RGSkipsm6z";
    
    _message1 = [LMMessage object];
    _message1.text = @"Hey";
    _message1.sender = _user1;

    _chat = [LMChat object];
    _chat.title = @"Chat Test";
    _chat.members = @[_user1, _user2];
    _chat.groupId = [_user1.objectId stringByAppendingString:_user2.objectId];
    _chat.messages = @[_message1];
    
    _chatFactory = [[LMChatFactory alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    _user1 = nil;
    _user2 = nil;
    _message1 = nil;
    _chat = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}


//[[[groupModelMock stub] andDo:^(NSInvocation *invoke) {
//    //2. declare a block with same signature
//    void (^weatherStubResponse)(NSDictionary *dict);
//    
//    //3. link argument 3 with with our block callback
//    [invoke getArgument:&weatherStubResponse atIndex:3];
//    
//    //4. invoke block with pre-defined input
//    NSDictionary *testResponse = @{@"high": 43 , @"low": 12};
//    weatherStubResponse(groupMemberMock);
//    
//}]downloadWeatherDataForZip@"80304" callback:[OCMArg any] ];
//OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);

//- (void)testDisplaysTweetsRetrievedFromConnection
//{
//    Controller *controller = [[[Controller alloc] init] autorelease];
//    
//    id mockConnection = OCMClassMock([TwitterConnection class]);
//    controller.connection = mockConnection;
//    
//    Tweet *testTweet = /* create a tweet somehow */;
//    NSArray *tweetArray = [NSArray arrayWithObject:testTweet];
//    OCMStub([mockConnection fetchTweets]).andReturn(tweetArray);
//    
//    [controller updateTweetView];
//}

-(void) testThatItCreatesAChat
{
    
    //given
    NSArray *chatMembers = @[_user1, _user2];
    NSDictionary *chatOptions = @{};
    
    id chatFactoryMock = OCMClassMock([LMChatFactory class]);
    
    
    [[chatFactoryMock stub] andDo:^(NSInvocation *invocation) {
        
        void (^LMInitiateChatCompletionBlock)(PFObject *chat, NSError *error);
        [invocation getArgument:&LMInitiateChatCompletionBlock atIndex:3];
        PFObject *testResponse = _chat;
        LMInitiateChatCompletionBlock(testResponse, nil);
        
    }];
    
    

    //when
    
    id mock = OCMClassMock([NSString class]);
    OCMStub([mock uppercaseString]).andReturn(@"Test_String");
    
    
    
    //then
    
    
    [chatFactoryMock stopMocking];
}

-(void)testThatLMChatViewControllerInitializes
{
//    LMChatViewController *chatVC = [[LMChatViewController alloc] initWithChat:_chat];
    
//    XCTAssertEqualObjects(, <#expression2, ...#>)(<#expression, ...#>)
    
}


@end
