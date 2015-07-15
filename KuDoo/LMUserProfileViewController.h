//
//  LMUserProfileViewController.h
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
 *  `LMUserProfileViewController` is the superclass used throughout KuDoo to display user media
 *
 *  ## Implementation Notes
 *
 *  'LMTableViewCell' is very similar to UITableViewCell style 1 with some custom layout implemented and an extra label added (customAccessoryView)
 *
 *  ## Usage Example
 *
 */

@import UIKit;

@class PFUser, LMUserViewModel;

@interface LMUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(instancetype) initWithUser:(PFUser *)user;

@property (nonatomic, strong, readonly) PFUser *user;

/*!
 @abstract The PFUser display name shown just above the profilePicView
 */
@property (nonatomic, strong, readonly) UILabel *usernameLabel;

/*!
 @abstract Handles configuring the raw user data to UI readable info
 
 @discussion See LMUserViewModel
 */
@property (nonatomic, strong, readonly) LMUserViewModel *viewModel;

/*!
 @abstract The users profile pictur centered near the top of the view
 
 @discussion Image is masked to a circle with a white border
 */
@property (nonatomic, strong, readonly) UIImageView *profilePicView;

/*!
 @abstract The background view of the user. If this is not specified it is set to the default background view
 
 @discussion Default background view is a picture of miami beach
 */
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

/*!
 @abstract Image displayed behind the user information which is obscured by a blur effect. Default image is the backgroundImageView image
 
 @discussion Default image is the backgroundImageView image
 */
@property (nonatomic, strong, readonly) UIImageView *tableBackgroundView;

/*!
 @abstract TableView displaying users information, displayed below the background image
 
 @discussion Information is configured by the view model to be UI friendly
 */
@property (nonatomic, strong, readonly) UITableView *userInformation;

/*!
 @abstract Short description provided by the user. Can be blank
 */
@property (nonatomic, strong, readonly) UITextView *bioTextView;

/*!
 @abstract Flag image matching the users native language
 */
@property (nonatomic, strong, readonly) UIImage *fluentImage;

/*!
 @abstract Flag image matching the users learning language
 */
@property (nonatomic, strong, readonly) UIImage *desiredImage;

@end
