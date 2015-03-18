#import "LMFriendsListViewCell.h"
#import "UIFont+ApplicationFonts.h"
#import <Parse/Parse.h>

@interface LMFriendsListViewCell()

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *friendNameLabel;
@property (strong, nonatomic) UILabel *friendLanguageLabel;

@end

static CGFloat cellHeight = 70;

@implementation LMFriendsListViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.profileImageView = [UIImageView new];
        self.profileImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.friendLanguageLabel = [UILabel new];
        self.friendLanguageLabel.font = [UIFont applicationFontSmall];
        [self.friendLanguageLabel sizeToFit];
        
        self.friendNameLabel = [UILabel new];
        self.friendNameLabel.font = [UIFont applicationFontLarge];
        [self.friendNameLabel sizeToFit];
        
        for (UIView *view in @[self.profileImageView, self.friendNameLabel, self.friendLanguageLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_profileImageView, _friendNameLabel, _friendLanguageLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_profileImageView]-[_friendNameLabel]"
                                                                            options:kNilOptions
                                                                            metrics:nil
                                                                              views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_profileImageView]-[_friendLanguageLabel]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_friendNameLabel(==37.5)][_friendLanguageLabel]"
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
    self.friendLanguageLabel.text = [NSString stringWithFormat:@"Learning: %@", user[@"desiredLanguage"]];
}

-(void)downloadProfilePictureForUser
{
    PFFile *profilePicFile = self.user[@"picture"];
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(cellHeight, cellHeight), NO, 0.0);
            UIImage *image = [UIImage imageWithData:data];
            [image drawInRect:CGRectMake(0, 0, cellHeight, cellHeight)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.profileImageView.image = newImage;
            
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
