//
//  LMSignUpView.h
//
//
//  Copyright (c) 2015 Travis Buttaccio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

/**
 *  `LMSignUpView` is the generic signup view used in KuDoo. Includes Facebook and Twitter login buttons.
 *
 *  ## Implementation Notes
 *
 *  Can be used as a generic sign up view
 *
 */

@import UIKit;
@class FBSDKLoginButton;

@protocol LMSignUpViewDelegate <NSObject>

@optional
-(void) userWithCredentials:(NSDictionary *)info pressedSignUpButton:(UIButton *)sender;
-(void) facebookButtonPressed:(UIButton *)sender;
-(void) twitterButtonPressed:(UIButton *)sender;
-(void) existingAccountButtonPressed: (UIButton *)sender;

@end

@interface LMSignUpView : UIView

@property (nonatomic, weak) id <LMSignUpViewDelegate> delegate;

/*!
 @abstract The title label displayed near the top of the view
 
 @discussion Used in KuDoo to display app name
 */
@property (strong, nonatomic, readonly) UILabel *titleLabel;

/*!
 @abstract Detail label just below the title label
 
 @discussion Use in KuDoo to display the app slogan
 */
@property (strong, nonatomic, readonly) UILabel *detailLabel;

/*!
 @abstract Text Field input for username
 */
@property (strong, nonatomic, readonly) UITextField *usernameField;

/*!
 @abstract Max characters allowed for the username
 
@discussion Default value is 20
 */
@property (assign, nonatomic) NSUInteger maxUsernameLength;

/*!
 @abstract Text Field input for password
 */
@property (strong, nonatomic, readonly) UITextField *passwordField;

/*!
 @abstract Text Field input for password
 */
@property (strong, nonatomic, readonly) UITextField *emailField;

/*!
 @abstract The signup button displayed below the email field
 
 @discussion Default size is 60.0f x 60.0f with a 30.0f corner radius and checkmark image
 */
@property (strong, nonatomic, readonly) UIButton *signUpButton;

/*!
 @abstract Facebook login located near the bottom of the view
 
 @discussion Implement delegate method to handle button presses
 */
@property (strong, nonatomic, readonly) FBSDKLoginButton *facebookLoginButton;

/*!
 @abstract Twitter login located near the bottom of the view, below the facebook login button
 
 @discussion Implement delegate method to handle button presses
 */
@property (strong, nonatomic, readonly) UIButton *twitterButton;

/*!
 @abstract Existing account button, displayed at the buttom of the view.
 
 @discussion Used in KuDoo to display the login page if tapped
 */
@property (strong, nonatomic, readonly) UIButton *existingAccountButton;

/*!
 @abstract Bool to indicate if there is an alert currently showing in the view
 
 @discussion Used for testing UI
 */
@property (nonatomic, assign) BOOL alertIsShowing;

@end
