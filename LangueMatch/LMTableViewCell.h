/*!
  LMTableCell.h
  KuDoo

  Created by Travis Buttaccio on 6/10/15.
  Copyright (c) 2015 KuDoo. All rights reserved.
    
  @discussion Superclass for LMTableViewCells
*/

@import UIKit;

@interface LMTableViewCell : UITableViewCell

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
 @abstract Label displayed on the right side of the cell, closer to the top
 
 @discussion Used in ChatsTableViewController to display the date of the last sent message
 */
@property (strong, nonatomic, readonly) UILabel *accessoryLabel;

/*!
 @abstract Text displayed on the right side of the cell, closer to the bottom. Background color is white if text, otherwise it is clear.
 
 @discussion Used in ChatsTableViewController to display the new message count
 */
@property (copy, nonatomic) NSString *customAccessoryLabelText;

@end
