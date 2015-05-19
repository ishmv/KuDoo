#import "LMChatListCell.h"
#import "UIFont+ApplicationFonts.h"
#import "AppConstant.h"
#import "Utility.h"

#import <Parse/Parse.h>

@interface LMChatListCell()

@end

@implementation LMChatListCell

-(void)setChat:(PFObject *)chat
{
    _chat = chat;
    [self p_downloadChatPicture];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", chat[PF_CHAT_TITLE]];
}

-(void) setLastMessage:(PFObject *)lastMessage
{
    _lastMessage = lastMessage;
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserUsername = currentUser.username;
    NSString *senderUserName = lastMessage[PF_MESSAGE_SENDER_NAME];
    
    NSMutableString *lastMessageText = ([currentUserUsername isEqualToString:senderUserName]) ? [NSMutableString stringWithString:@"You"] : [NSMutableString stringWithString:lastMessage[PF_MESSAGE_SENDER_NAME]];
    
    if (lastMessage[PF_MESSAGE_TEXT])  [lastMessageText appendString: [NSString stringWithFormat:@": %@", lastMessage[PF_MESSAGE_TEXT]]];
    else if (lastMessage[PF_MESSAGE_AUDIO]) [lastMessageText appendString: @" sent audio message"];
    else if (lastMessage[PF_MESSAGE_VIDEO]) [lastMessageText appendString: @" sent a video"];
    else if (lastMessage[PF_MESSAGE_IMAGE]) [lastMessageText appendString: @" sent a picture"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    formatter.dateFormat = @"EEE, MMM d 'at' hh:mm aaa";
    
    self.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.detailLabel.text = lastMessageText;
    
    NSString *dateText = [formatter stringFromDate:lastMessage.updatedAt];
    self.accessoryLabel.text = [NSString stringWithFormat:@"%@", dateText];
    
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    ALIGN_VIEW_TOP_CONSTANT(self, self.accessoryLabel, -10);
}


#pragma mark - Private Methods

-(void) p_downloadChatPicture
{
    PFFile *chatPicture = self.chat[@"picture"];
    [chatPicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.cellImageView.image = image;
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
