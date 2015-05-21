#import "LMFriendListCell.h"
#import "UIFont+ApplicationFonts.h"
#import "Utility.h"
#import "UIColor+applicationColors.h"
#import "AppConstant.h"

#import <Parse/Parse.h>

@interface LMFriendListCell()

@end

@implementation LMFriendListCell

-(void)setUser:(PFUser *)user
{
    _user = user;
    
    [self downloadProfilePictureForUser];
    
    NSString *upperCaseDesired = [user[PF_USER_DESIRED_LANGUAGE] uppercaseString];
    NSString *upperCaseFluent = [user[PF_USER_FLUENT_LANGUAGE] uppercaseString];
    
    self.titleLabel.text = user[@"username"];
    self.accessoryLabel.text = [NSString stringWithFormat:@"%@", upperCaseDesired];
    
    NSString *fluentLanguageText = [NSString stringWithFormat:@"KNOWS %@", upperCaseFluent];
    self.detailLabel.text = NSLocalizedString(fluentLanguageText, fluentLanguageText);
}

-(void)downloadProfilePictureForUser
{
    PFFile *profilePicFile = self.user[PF_USER_THUMBNAIL];
    
    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
    
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                self.cellImageView.image = image;
            });
        } else {
            NSLog(@"There was an error retrieving profile picture");
        }
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
