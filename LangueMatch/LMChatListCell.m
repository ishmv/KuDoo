#import "LMChatListCell.h"
#import "UIFont+ApplicationFonts.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMChatListCell()

@property (strong, nonatomic) UIImageView *chatImageView;
@property (strong, nonatomic) UILabel *chatTitle;
@property (strong, nonatomic) UILabel *dateLabel;

@end

static CGFloat cellHeight = 70;

@implementation LMChatListCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.chatImageView = [UIImageView new];
        self.chatImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.chatTitle = [UILabel new];
        self.chatTitle.font = [UIFont applicationFontLarge];
        [self.chatTitle sizeToFit];
        
        self.dateLabel = [UILabel new];
        self.dateLabel.font = [UIFont applicationFontSmall];
        [self.dateLabel sizeToFit];
        
        for (UIView *view in @[self.chatImageView, self.chatTitle, self.dateLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_chatImageView, _chatTitle, _dateLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chatImageView]-8-[_chatTitle]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chatImageView]-8-[_dateLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_chatTitle(==50)][_dateLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];

}


#pragma mark - Setter Methods
-(void)setChat:(PFObject *)chat
{
    _chat = chat;
    
    [self downloadChatPicture];
    self.chatTitle.text = [NSString stringWithFormat:@"%@", chat[PF_CHAT_TITLE]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd 'at' HH:mm";
    self.dateLabel.text = [formatter stringFromDate:chat.updatedAt];
}

-(void)downloadChatPicture
{
    PFFile *chatPicture = self.chat[@"picture"];
    [chatPicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(cellHeight, cellHeight), NO, 0.0);
            UIImage *image = [UIImage imageWithData:data];
            [image drawInRect:CGRectMake(0, 0, cellHeight, cellHeight)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.chatImageView.image = newImage;
            
            UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(35, 35) radius:35 startAngle:0 endAngle:2*M_PI clockwise:YES];
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.path = clippingPath.CGPath;
            self.chatImageView.layer.mask = mask;

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
