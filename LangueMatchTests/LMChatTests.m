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

#import "AppConstant.h"


NSString *const kParseApplicationID = @"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz";
NSString *const kParseClientID = @"fRQkUVPDjp9VMkiWkD6KheVBtxewtiMx6IjKBdXh";

@interface LMChatTests : XCTestCase

@property (strong, nonatomic) PFUser *testUser1;
@property (strong, nonatomic) PFUser *testUser2;
@property (strong, nonatomic) PFUser *testUser3;

@end

@implementation LMChatTests

- (void)setUp {
    [super setUp];
    
    [Parse setApplicationId:kParseApplicationID clientKey:kParseClientID];
    
    NSString *name1 = @"testUser1";
    NSString *email1 = @"testUser1@mail.com";
    NSString *password1 = @"testUser1Password";
    NSString *fluentLanguage1 = @"english";
    NSString *desiredLanguage1 = @"japanese";
    UIImage *image1 = [UIImage imageNamed:@"emptyprofilepicture.jpg"];
    NSData *imageData1 = UIImageJPEGRepresentation(image1, 0.9);
    PFFile *testUserPic1 = [PFFile fileWithData:imageData1];
    
    NSString *name2 = @"testUser2";
    NSString *email2 = @"testUser2@mail.com";
    NSString *password2 = @"testUserPassword2";
    NSString *fluentLanguage2 = @"japanese";
    NSString *desiredLanguage2 = @"english";
    
    NSString *name3 = @"testUser3";
    NSString *email3 = @"testUser3@mail.com";
    NSString *password3 = @"testUserPassword3";
    NSString *fluentLanguage3 = @"spanish";
    NSString *desiredLanguage3 = @"japanese";
    
    _testUser1 = [PFUser new];
    _testUser1.username = name1;
    _testUser1[PF_USER_USERNAME_LOWERCASE] = [name1 lowercaseString];
    _testUser1.email = email1;
    _testUser1[PF_USER_EMAILCOPY] = [email1 lowercaseString];
    _testUser1.password= password1;
    _testUser1[PF_USER_FLUENT_LANGUAGE] = fluentLanguage1;
    _testUser1[PF_USER_DESIRED_LANGUAGE] = desiredLanguage1;
    _testUser1[PF_USER_PICTURE] = testUserPic1;
    _testUser1[PF_USER_THUMBNAIL] = testUserPic1;
    _testUser1.objectId = @"testObjectId1";
    
    _testUser2 = [PFUser new];
    _testUser2.username = name2;
    _testUser2[PF_USER_USERNAME_LOWERCASE] = [name2 lowercaseString];
    _testUser2.email = email2;
    _testUser2[PF_USER_EMAILCOPY] = [email2 lowercaseString];
    _testUser2.password= password2;
    _testUser2[PF_USER_FLUENT_LANGUAGE] = fluentLanguage2;
    _testUser2[PF_USER_DESIRED_LANGUAGE] = desiredLanguage2;
    _testUser2[PF_USER_PICTURE] = testUserPic1;
    _testUser2[PF_USER_THUMBNAIL] = testUserPic1;
    _testUser2.objectId = @"testObjectId2";
    
    _testUser3 = [PFUser new];
    _testUser3.username = name3;
    _testUser3[PF_USER_USERNAME_LOWERCASE] = [name3 lowercaseString];
    _testUser3.email = email3;
    _testUser3[PF_USER_EMAILCOPY] = [email3 lowercaseString];
    _testUser3.password= password3;
    _testUser3[PF_USER_FLUENT_LANGUAGE] = fluentLanguage3;
    _testUser3[PF_USER_DESIRED_LANGUAGE] = desiredLanguage3;
    _testUser3[PF_USER_PICTURE] = testUserPic1;
    _testUser3[PF_USER_THUMBNAIL] = testUserPic1;
    _testUser3.objectId = @"testObjectId3";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//-(void) testThatLMChatFactoryCreatesTwoPersonChat
//{
//    NSString *testGroupId = [_testUser1.objectId stringByAppendingString:_testUser2.objectId];
//    
//    id testUserMock = OCMClassMock([PFUser class]);
//    OCMStub([testUserMock currentUser]).andReturn(_testUser1);
//    OCMStub([testUserMock isAuthenticated]).andReturn(1);
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
//    
//    [LMChatFactory createChatForUser:_testUser1 withMembers:@[_testUser1, _testUser2] chatDetails:@{} andCompletion:^(PFObject *chat, NSError *error) {
//        [expectation fulfill];
//        XCTAssertTrue([chat[PF_CHAT_GROUPID] isEqualToString:testGroupId]);
//    }];
//    
//    [self waitForExpectationsWithTimeout:0.5 handler:nil];
//    [testUserMock stopMocking];
//}


-(void) testParseCloudSampleCode
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    [PFCloud callFunctionInBackground:@"hello" withParameters:@{} block:^(NSString *result, NSError *error) {
        [expectation fulfill];
        NSLog(@"%@", result);
        XCTAssert([result isEqualToString:@"Hello world!"]);
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

-(void) testParseCloudGetsUser
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    NSDictionary *parameters = @{
                                 @"userId" : @"4283dTXhg6",
                                 @"groupId" : @"testGroupId"
                                 };
    
    [PFCloud callFunctionInBackground:@"getUser" withParameters:parameters block:^(id result, NSError *error) {
        [expectation fulfill];
        PFUser *user = (PFUser *)result[0];
        NSLog(@"%@", result);
        XCTAssert([user.objectId isEqualToString:@"4283dTXhg6"]);
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

-(void) testSavingMultipleItemsToParseArray
{
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    PFQuery *queryTestClass = [PFQuery queryWithClassName:@"TestClass"];
    [queryTestClass whereKey:@"testing" equalTo:@"testing"];
    [queryTestClass getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        for (int i = 6; i < 11; i++) {
            PFObject *user = [PFObject objectWithClassName:@"TestUserClass"];
            user[@"username"] = [NSString stringWithFormat:@"user%@", @(i)];
            [object addObject:user forKey:@"TestUsers"];
            
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (i == 10) {
                    [expectation fulfill];
                }
            }];
        }
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

-(void) testParseCloudGetsSeveralUsers
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    NSDictionary *parameters = @{
                                 @"userId" : @"4283dTXhg6",
                                 @"groupId" : @"testGroupId"
                                 };
    
    [PFCloud callFunctionInBackground:@"getUser" withParameters:parameters block:^(id result, NSError *error) {
        [expectation fulfill];
        PFUser *user = (PFUser *)result[0];
        NSLog(@"%@", result);
        XCTAssert([user.objectId isEqualToString:@"4283dTXhg6"]);
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

-(void) testObjectIdIsNullUntilSavedToParse
{
    PFObject *testObject = [PFObject objectWithClassName:@"TestClass"];
    testObject[@"testing"] = @"testing";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    XCTAssertFalse(testObject.objectId);
    NSLog(@"%@", testObject.objectId);
    
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [expectation fulfill];
        XCTAssertFalse(testObject.isDirty);
        NSLog(@"%@", testObject.objectId);
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    [testObject deleteInBackground];
}

-(void) testDataSyncingWithRelationship
{
    PFObject *testObject = [PFObject objectWithClassName:@"TestClass"];
    testObject[@"testing"] = @"testing";
    
    PFObject *user = [PFObject objectWithClassName:@"TestUserClass"];
    user[@"username"] = @"bobby";
    
    testObject[@"user"] = user;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [expectation fulfill];
        XCTAssertFalse(testObject.isDirty);
        XCTAssertFalse(user.isDirty);
        NSLog(@"%@", user.objectId);
        NSLog(@"%@", testObject.objectId);
        NSLog(@"%@", testObject.description);
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    [testObject deleteInBackground];
    [user deleteInBackground];
}

-(void) testThatPinningAutomaticallyUpdatesWhenSaving
{
    PFObject *testObject = [PFObject objectWithClassName:@"TestClass"];
    testObject[@"testing"] = @"testing";
    
    PFObject *user = [PFObject objectWithClassName:@"TestUserClass"];
    user[@"username"] = @"bobby";
    
    testObject[@"user"] = user;
    
    [testObject pinInBackground];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Handler 2 Called"];
    
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [expectation fulfill];
        XCTAssertFalse(testObject.isDirty);
        XCTAssertFalse(user.isDirty);
        NSLog(@"%@", user.objectId);
        NSLog(@"%@", testObject.objectId);
        NSLog(@"%@", testObject.description);
        
        PFQuery *queryDataStore = [PFQuery queryWithClassName:@"TestClass"];
        [queryDataStore fromLocalDatastore];
        [queryDataStore whereKey:@"testing" equalTo:@"testing"];
        [queryDataStore getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [expectation2 fulfill];
            XCTAssertTrue([object[@"TestUserClass"] isEqualToString:@"bobby"]);
            
        }];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    [testObject unpinInBackground];
    [testObject deleteInBackground];
    [user deleteInBackground];
}




@end
