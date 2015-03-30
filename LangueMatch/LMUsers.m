#import "LMUsers.h"
#import "AppConstant.h"

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface LMUsers()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *randomUsers;

@end

@implementation LMUsers

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init
{
    if (self = [super init]) {
    }
    return self;
}

/* Queries server for fluent language equal to desired language  
 
 Filters results to exclude friends and self 
 Query limit set at 100
 
 */

-(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion
{

    PFUser *currentUser = [PFUser currentUser];
    NSString *desiredLanguage = currentUser[PF_USER_DESIRED_LANGUAGE];
    NSString *fluentLanguage = currentUser[PF_USER_FLUENT_LANGUAGE];
    
    NSArray *friendsArray = currentUser[PF_USER_FRIENDS];
    NSMutableArray *friendIds = [NSMutableArray array];
    
    //Exclude current user from search
    [friendIds addObject:currentUser.objectId];
    
    //Get friends object Ids to query against
    for (PFUser *friend in friendsArray) {
        [friendIds addObject:friend.objectId];
    }
    
    // if user base grows will need to change algorithm to query count number of objects first then choose one at random
    
    PFQuery *desiredQuery = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [desiredQuery whereKey:PF_USER_FLUENT_LANGUAGE equalTo:desiredLanguage];
    [desiredQuery limit];
    
    [desiredQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects) {
            
            NSMutableArray *matches = [NSMutableArray arrayWithArray:objects];
            NSMutableArray *dualMatches = [NSMutableArray array];
            
            for (PFUser *user in matches) {
                if ([user[PF_USER_DESIRED_LANGUAGE] isEqualToString:fluentLanguage] && ![friendIds containsObject:user.objectId]) {
                        [dualMatches addObject:user];

                }
            }
            
            int matchCount = (int)[dualMatches count];
            if (matchCount) {
                NSUInteger randomSelection = arc4random_uniform(matchCount);
                PFUser *randomUser = dualMatches[randomSelection];
                completion(randomUser, error);
                
            }
            
        } else {
            NSLog(@"Error Finding partners %@", error);
        }
    }];
}

/* Saves user profile picture after changing */

-(void)saveUserProfileImage:(UIImage *)image
{
    PFUser *user = [PFUser currentUser];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    PFFile *imageFile = [PFFile fileWithName:@"picture" data:imageData];
    
    //Set Thumbnail
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(70, 70), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 70, 70)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbnailData = UIImageJPEGRepresentation(newImage, 1.0);
    PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail" data:thumbnailData];
    
    user[@"picture"] = imageFile;
    user[@"thumbnail"] = thumbnailFile;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
        } else {
            NSLog(@"There was an error getting the image");
        }
    }];
}



@end

