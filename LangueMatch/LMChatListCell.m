#import "LMChatListCell.h"
#import "UIFont+ApplicationFonts.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMChatListCell()

@property (strong, nonatomic) UILabel *chatTitle;
@property (strong, nonatomic) UILabel *dateLabel;

@end

static CGFloat cellHeight = 70;

@implementation LMChatListCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
    
        self.imageView.frame = CGRectMake(15, 0, cellHeight, cellHeight);
        self.imageView.contentMode = UIViewContentModeScaleToFill;

        self.chatTitle = [UILabel new];
        self.chatTitle.font = [UIFont applicationFontLarge];
        [self.chatTitle sizeToFit];
        
        self.dateLabel = [UILabel new];
        self.dateLabel.font = [UIFont applicationFontSmall];
        [self.dateLabel sizeToFit];
        
        for (UIView *view in @[self.chatTitle, self.dateLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_chatTitle, _dateLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[_chatTitle]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[_dateLabel]"
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
    
    [self downloadPictureForChat];
    
    self.chatTitle.text = [NSString stringWithFormat:@"Chat with %@", chat[PF_CHAT_TITLE]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd 'at' HH:mm";
    self.dateLabel.text = [formatter stringFromDate:chat.updatedAt];
}

-(void)downloadPictureForChat
{
    PFUser *sender = self.chat[PF_CHAT_RECEIVER];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID equalTo:sender.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        PFFile *chatImage = user[PF_USER_THUMBNAIL];
        
        [chatImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         
         {
             if (!error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.imageView.image = [UIImage imageWithData:data];
                     [self addPictureMask];
                     [self setNeedsDisplay];
                 });
                 
             } else {
                 NSLog(@"There was an error retrieving profile picture");
             }
         }];
    }];
}

-(void) addPictureMask
{
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds)) radius:35 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    self.imageView.layer.mask = mask;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
