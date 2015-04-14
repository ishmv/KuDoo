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
        
    
        self.imageView.frame = CGRectMake(0, 0, cellHeight, cellHeight);
        self.imageView.contentMode = UIViewContentModeScaleToFill;

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
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
    
    self.chatTitle.text = [NSString stringWithFormat:@"Chat with %@", chat[PF_CHAT_TITLE]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd 'at' HH:mm";
    self.dateLabel.text = [formatter stringFromDate:chat.updatedAt];
}

-(void)setChatImage:(UIImage *)chatImage
{
    _chatImage = chatImage;
    
    self.imageView.image = chatImage;
    
    UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds)) radius:35 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = clippingPath.CGPath;
    self.imageView.layer.mask = mask;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
