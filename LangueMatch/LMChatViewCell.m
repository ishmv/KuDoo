#import "LMChatViewCell.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMChatViewCell()

@property (strong, nonatomic) UILabel *mainText;
@property (strong, nonatomic) UILabel *senderLabel;
@property (strong, nonatomic) UIImageView *bubbleView;
@property (nonatomic, assign) int senderId;

@end

@implementation LMChatViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier:reuseIdentifier]) {
        self.mainText = [UILabel new];
        self.mainText.backgroundColor = [UIColor clearColor];

        self.bubbleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble_stroked.png"]];
        self.bubbleView.contentMode = UIViewContentModeScaleAspectFill;
        
        for (UIView *view in @[self.bubbleView, self.mainText]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    self.bubbleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    
    //    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mainText, _bubbleView);
    
    [self alignViewVerticallyCenterWithContentView:self.mainText];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainText
                                                                 attribute:self.senderId
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:self.senderId
                                                                multiplier:1.0f
                                                                  constant:0.0]];
    
    
}

-(void)setMessage:(PFObject *)message
{
    _message = message;
    
    self.mainText.text = message[@"text"];
    [self.mainText sizeToFit];
    
    if ([self.message[@"senderName"] isEqualToString:[PFUser currentUser].username]) {
        self.senderId = NSLayoutAttributeRightMargin;
    } else {
        self.senderId = NSLayoutAttributeLeftMargin;
    }
    
    //Update Constants!!
}


-(void) alignViewVerticallyCenterWithContentView:(UIView *)view
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
