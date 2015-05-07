#import "LMListViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"

#import <Parse/Parse.h>

@interface LMListViewCell()

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *friendNameLabel;
@property (strong, nonatomic) UILabel *learningLanguageLabel;
@property (strong, nonatomic) UILabel *fluentLanguageLabel;

@end

static CGFloat cellHeight = 70;

@implementation LMListViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.profileImageView = [UIImageView new];
        self.profileImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.learningLanguageLabel = [UILabel new];
        self.learningLanguageLabel.font = [UIFont lm_applicationFontSmall];
        [self.learningLanguageLabel sizeToFit];
        
        self.fluentLanguageLabel = [UILabel new];
        self.fluentLanguageLabel.font = [UIFont lm_applicationFontSmall];
        [self.fluentLanguageLabel sizeToFit];
        
        self.friendNameLabel = [UILabel new];
        self.friendNameLabel.font = [UIFont lm_applicationFontLarge];
        [self.friendNameLabel sizeToFit];
        
        for (UIView *view in @[self.profileImageView, self.friendNameLabel, self.learningLanguageLabel, self.fluentLanguageLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_profileImageView, _friendNameLabel, _learningLanguageLabel, _fluentLanguageLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_profileImageView]-8-[_friendNameLabel]"
                                                                            options:kNilOptions
                                                                            metrics:nil
                                                                              views:viewDictionary]];
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _learningLanguageLabel, 0);
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, _fluentLanguageLabel, 0);

    CONSTRAIN_HEIGHT(_friendNameLabel, cellHeight);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_learningLanguageLabel(==37.5)][_fluentLanguageLabel(==37.5)]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
}


#pragma mark - Setter Methods
-(void)setUser:(PFUser *)user
{
    _user = user;
    
    [self downloadProfilePictureForUser];
    
    self.friendNameLabel.text = user[@"username"];
    self.learningLanguageLabel.text = [NSString stringWithFormat:@"Learning: %@", user[@"desiredLanguage"]];
    self.fluentLanguageLabel.text = [NSString stringWithFormat:@"Fluent In: %@", user[@"fluentLanguage"]];
}

-(void)downloadProfilePictureForUser
{
    PFFile *profilePicFile = self.user[@"thumbnail"];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
    
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(cellHeight, cellHeight), NO, 0.0);
            UIImage *image = [UIImage imageWithData:data];
            [image drawInRect:CGRectMake(0, 0, cellHeight, cellHeight)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.profileImageView.image = newImage;
            
            UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(35, 35) radius:35 startAngle:0 endAngle:2*M_PI clockwise:YES];
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.path = clippingPath.CGPath;
            self.profileImageView.layer.mask = mask;
            
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
