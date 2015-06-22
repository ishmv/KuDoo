#import "ParseConnection.h"
#import "AppConstant.h"

#import "NSArray+LanguageOptions.h"

@implementation ParseConnection

+(void) signupUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion
{
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completion(succeeded, error);
    }];
}

+(void) loginUser:(NSString *)username withPassword:(NSString *)password withCompletion:(PFUserResultBlock)completion
{
    [PFUser logInWithUsernameInBackground:[username lowercaseString] password:password block:^(PFUser *user, NSError *error) {
        completion(user, error);
    }];
}

+(void) setUserOnlineStatus:(BOOL)online
{
    PFUser *currentUser = [PFUser currentUser];
    currentUser[PF_USER_ONLINE] = @(online);
    [currentUser saveEventually];
}

+(void) searchForUsername:(NSString *)username withCompletion:(PFArrayResultBlock)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME containsString:[username lowercaseString]];
    [query setLimit:20];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        completion(users, error);
    }];
}

+(void) searchForUserIds:(NSArray *)userIds withCompletion:(PFArrayResultBlock)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID containedIn:userIds];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        completion(users, error);
    }];
}

+(void)saveUserImage:(UIImage *)image forType:(LMUserPicture)pictureType
{
    PFUser *user = [PFUser currentUser];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    PFFile *imageFile = [PFFile fileWithName:@"picture" data:imageData];
    
    //Set Thumbnail
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(70, 70), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 70, 70)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbnailData = UIImageJPEGRepresentation(newImage, 0.8);
    PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail" data:thumbnailData];
    
    if (pictureType == LMUserPictureSelf) {
        user[PF_USER_PICTURE] = imageFile;
        user[PF_USER_THUMBNAIL] = thumbnailFile;
    } else {
        user[PF_USER_BACKGROUND_PICTURE] = imageFile;
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
        } else {
            NSLog(@"There was an error getting the image");
        }
    }];
}

+(void)saveUserLanguageSelection:(NSInteger)languageIndex forType:(LMLanguageSelectionType)type
{
    PFUser *user = [PFUser currentUser];
    
    switch (type) {
        case LMLanguageSelectionTypeDesired:
            user[PF_USER_DESIRED_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][languageIndex] lowercaseString];
            break;
        case LMLanguageSelectionTypeFluent1:
            user[PF_USER_FLUENT_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][languageIndex] lowercaseString];
            break;
        case LMLanguageSelectionTypeFluent2:
            user[PF_USER_FLUENT_LANGUAGE2] = [[NSArray lm_languageOptionsEnglish][languageIndex] lowercaseString];
            break;
        case LMLanguageSelectionTypeFluent3:
            user[PF_USER_FLUENT_LANGUAGE3] = [[NSArray lm_languageOptionsEnglish][languageIndex] lowercaseString];
            break;
        default:
            break;
    }
    
    [user saveEventually];
}

+(void)saveUsersUsername:(NSString *)username
{
    PFUser *user = [PFUser currentUser];
    user.username = [username lowercaseString];
    user[PF_USER_DISPLAYNAME] = username;
    [user saveEventually];
}

+(void) saveUserLocation:(NSString *)location
{
    PFUser *currentUser = [PFUser currentUser];
    currentUser[PF_USER_LOCATION] = location;
    currentUser[PF_USER_LOCATION_LOWER] = [location lowercaseString];
    [currentUser saveEventually];
}

+(void) saveUserBio:(NSString *)bio
{
    PFUser *currentUser = [PFUser currentUser];
    currentUser[PF_USER_BIO] = bio;
    [currentUser saveEventually];
}

+(void) performSearchType:(LMSearchType)searchType withParameter:(NSString *)parameter withCompletion:(PFArrayResultBlock)completion
{
    PFQuery *userSearch = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    
    PFUser *currentUser = [PFUser currentUser];
    
    switch (searchType) {
        case LMSearchTypeOnline:
            break;
        case LMSearchTypeUsername:
            [userSearch whereKey:PF_USER_USERNAME containsString:[parameter lowercaseString]];
            break;
        case LMSearchTypeLocation:
            [userSearch whereKey:PF_USER_LOCATION_LOWER containsString:[parameter lowercaseString]];
            break;
        case LMSearchTypeFluentLanguage:
        {
            PFQuery *subQuery1 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery1 whereKey:PF_USER_FLUENT_LANGUAGE containsString:[parameter lowercaseString]];
            
            PFQuery *subQuery2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery2 whereKey:PF_USER_FLUENT_LANGUAGE2 containsString:[parameter lowercaseString]];
            
            PFQuery *subQuery3 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery3 whereKey:PF_USER_FLUENT_LANGUAGE3 containsString:[parameter lowercaseString]];
            
            userSearch = [PFQuery orQueryWithSubqueries:@[subQuery1, subQuery2, subQuery3]];
        }
            break;
        case LMSearchTypeLearningLanguage:
            [userSearch whereKey:PF_USER_DESIRED_LANGUAGE containsString:[parameter lowercaseString]];
            break;
        case LMSearchTypePairMe:
        {
            NSMutableArray *matches = [[NSMutableArray alloc] init];
            
            PFQuery *subQuery1 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery1 whereKey:PF_USER_FLUENT_LANGUAGE containsString:currentUser[PF_USER_DESIRED_LANGUAGE]];
            
            PFQuery *subQuery2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery2 whereKey:PF_USER_FLUENT_LANGUAGE2 containsString:currentUser[PF_USER_DESIRED_LANGUAGE]];
            
            PFQuery *subQuery3 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [subQuery3 whereKey:PF_USER_FLUENT_LANGUAGE3 containsString:currentUser[PF_USER_DESIRED_LANGUAGE]];
            
            userSearch = [PFQuery orQueryWithSubqueries:@[subQuery1, subQuery2, subQuery3]];
            [userSearch whereKey:PF_USER_ONLINE equalTo:@(YES)];
            [userSearch setLimit:20];
            [userSearch findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFUser *user in objects) {
                    if ([user[PF_USER_DESIRED_LANGUAGE] isEqualToString:[currentUser[PF_USER_FLUENT_LANGUAGE] lowercaseString]] || [user[PF_USER_DESIRED_LANGUAGE] isEqualToString:[currentUser[PF_USER_FLUENT_LANGUAGE2] lowercaseString]] || [user[PF_USER_DESIRED_LANGUAGE] isEqualToString:[currentUser[PF_USER_FLUENT_LANGUAGE3] lowercaseString]]) {
                        [matches addObject:user];
                    }
                }
                completion(matches, error);
            }];
        }

            break;
        default:
            break;
    }
    
    if (searchType != LMSearchTypePairMe) {
        
        [userSearch whereKey:PF_USER_ONLINE equalTo:@(YES)];
        [userSearch setLimit:20];
        
        [userSearch findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            completion(objects, error);
        }];
    }
    
}

@end

