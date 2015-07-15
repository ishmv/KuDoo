//
//  LMTableViewCell.h
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
 *  `LMTableViewCell` is a subclass of UITableViewCell used throughout KuDoo as UITableViewCell superclass
 *
 *  ## Implementation Notes
 *
 *  'LMTableViewCell' is very similar to UITableViewCell style 1 with some custom layout implemented and an extra label added (customAccessoryView)
 *
 *  ## Usage Example
 *
 */


@import UIKit;

@interface LMTableViewCell : UITableViewCell

/*!
 @abstract The minimum cell spacing used for content near the edge of the frame
 
 @discussion default value is 12.0f
 */
@property (assign, nonatomic) CGFloat minimumEdgeSpacing;

/*!
 @abstract The padding to apply to the cellImageView, equal on all sides
 
 @discussion default value is 0.0f. The image height and width is set to the height of the cell.
 */
@property (assign, nonatomic) CGFloat cellImageViewPadding;

/*!
 @abstract Offset applied to the title label.
 
 @discussion default value is 0.0f. Can use to center the label if not using detail label.
 */
@property (assign, nonatomic) CGFloat titleOffset;

/*!
 @abstract The cell image view displayed on the left side of the clel
 
 @discussion Used to display user profile pictures
 */
@property (strong, nonatomic, readonly) UIImageView *cellImageView;

/*!
 @abstract Label displayed prominently on the left side of the cell, next to the cell Image
 
 @discussion Used in ChatsTableViewController to display the name of the chat
 */
@property (strong, nonatomic, readonly) UILabel *titleLabel;

/*!
 @abstract Label displayed on the left side of the cell, beneath the title label
 
 @discussion Used in ChatsTableViewController to display the last sent message
 */
@property (strong, nonatomic, readonly) UILabel *detailLabel;

/*!
 @abstract Label displayed on the right side of the cell, near the top
 
 @discussion Used in ChatsTableViewController to display the date of the last sent message
 */
@property (strong, nonatomic, readonly) UILabel *accessoryLabel;

/*!
 @abstract Text displayed on the right side of the cell, closer to the bottom. Background color is white if text, otherwise it is clear.
 
 @discussion Used in ChatsTableViewController to display the new message count
 */
@property (copy, nonatomic) NSString *customAccessoryLabelText;

@end
