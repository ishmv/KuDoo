//
//  LMSignUpViewTests.m
//  KuDoo
//
//  Created by Travis Buttaccio on 7/9/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMSignUpView.h"
#import "AppConstant.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface LMSignUpViewTests : XCTestCase

@property (strong, nonatomic) id signupViewMock;

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;

@property (strong, nonatomic) NSDictionary *userCredentials;

@end

@implementation LMSignUpViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    LMSignUpView *signupView = [[LMSignUpView alloc] init];
    
    _signupViewMock = OCMPartialMock(signupView);
    
    _email = @"username@gmail.com";
    _username = @"username";
    _password = @"username";
    
    _userCredentials = @{PF_USER_USERNAME : _username, PF_USER_DISPLAYNAME : _username, PF_USER_EMAIL : _email, PF_USER_PASSWORD : _password};
}

- (void)tearDown {

    _email = nil;
    _username = nil;
    _password = nil;
    _userCredentials = nil;
    
    [_signupViewMock stopMocking];
    
    [super tearDown];
}

- (void) testBlankUsernameThrowsErrorAlert
{
    //Given
    [self p_setUsernameField:@" " password:_password email:_email];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(YES, [_signupViewMock alertIsShowing]);
}

-(void) testBlankPasswordFieldThrowsErrorAlert
{
    //Given
    [self p_setUsernameField:_username password:@" " email:_email];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(YES, [_signupViewMock alertIsShowing]);
}

-(void) testUsernameUnderFiveCharactersThrowsErrorAlert
{
    //Given
    [self p_setUsernameField:@"1234" password:_password email:_email];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(YES, [_signupViewMock alertIsShowing]);
}

-(void) testBlankEmailThrowsAlert
{
    //Given
    [self p_setUsernameField:_username password:_password email:@" "];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(YES, [_signupViewMock alertIsShowing]);
}

-(void) testEmailWithoutAtCharacterThrowsErrorAlert
{
    //Given
    [self p_setUsernameField:_username password:_password email:@"usernameAthotmail.com"];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(YES, [_signupViewMock alertIsShowing]);
}

-(void) testProperCredentialsDoesNotThrowErrorAlert
{
    //Given
    [self p_setUsernameField:_username password:_password email:_email];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    XCTAssertEqual(NO, [_signupViewMock alertIsShowing]);
}

-(void) testThatDelegateMethodIsCalledForSignupWithProperCredentials
{
    id signupViewDelegateMock = OCMProtocolMock(@protocol(LMSignUpViewDelegate));;
    
    OCMStub([_signupViewMock delegate]).andReturn(signupViewDelegateMock);

    [[signupViewDelegateMock expect] userWithCredentials:_userCredentials pressedSignUpButton:[_signupViewMock signUpButton]];
    
    //Given
    [self p_setUsernameField:_username password:_password email:_email];
    
    //When
    [[_signupViewMock signUpButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Then
    [signupViewDelegateMock verify];
    
    [signupViewDelegateMock stopMocking];
}

#pragma mark - Private Methods

-(void) p_setUsernameField:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    [[_signupViewMock usernameField] setText:username];
    [[_signupViewMock passwordField] setText:password];
    [[_signupViewMock emailField] setText:email];
}

@end
