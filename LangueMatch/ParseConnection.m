#import "ParseConnection.h"
#import "AppConstant.h"

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

+(void)saveUserLanguageSelection:(LMLanguageSelection)language forType:(LMLanguageSelectionType)type
{
    PFUser *user = [PFUser currentUser];
    
    if (type == LMLanguageSelectionTypeDesired) {
        user[PF_USER_DESIRED_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][language] lowercaseString];
    } else if (type == LMLanguageSelectionTypeFluent1) {
        user[PF_USER_FLUENT_LANGUAGE] = [[NSArray lm_languageOptionsEnglish][language] lowercaseString];
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
    [currentUser saveEventually];
}

@end

