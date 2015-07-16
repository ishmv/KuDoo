//
//  LMSignUpViewController.h
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
 *  `LMSignUpViewController` handles the sign up logic for KuDoo
 *
 *  ## Implementation Notes
 *
 *  The view controller relies on ParseConnection to signup new users, Facebook and Twitter signup requests prompts the user to authenticate their social account.
 *    Once the user logs in the view controller handles downloading the users picture and username and saving it to the Parse user database. Once signup is complete the delegate method is called.
 *  
 *  See ParseConnection.h - a helper class to make calls to the Parse backend. Used for saving user data.
 */


@import UIKit;
@class LMSignUpViewController, PFUser;

typedef NS_ENUM(NSInteger, socialMedia) {
    socialMediaNone,
    socialMediaFacebook,
    socialMediaTwitter
};

@protocol LMSignUpViewControllerDelegate <NSObject>

@optional
-(void) signupViewController:(LMSignUpViewController *)viewController didSignupUser:(PFUser *)user withSocialMedia:(socialMedia)social;
-(void) signupViewController:(LMSignUpViewController *)viewController didLoginUser:(PFUser *)user withSocialMedia:(socialMedia)social; //Called if user has already signed up with social media account

@end

@interface LMSignUpViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/*!
 @abstract A delegate that responds to sign up events
 */
@property (weak, nonatomic) id <LMSignUpViewControllerDelegate> delegate;

/*!
 @abstract The signup view displayed by the view controller.
 
 @discussion The signupView frame is set to the same size as the view controller frame size. The default signupView is LMSignupView.
 */
@property (strong, nonatomic) UIView *signUpView;

@end
