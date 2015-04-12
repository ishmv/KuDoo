#import "LMUsers.h"

#import <Parse/Parse.h>


@interface LMUsers()

@end

@implementation LMUsers

/* Queries server for fluent language equal to desired language  
 
 Filters results to exclude friends and self 
 Query limit set at 100
 
 */

+(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion
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
                
                //Send notification to user to check if they are available - if so send completion
//                [self sendChatRequestNotificationTo:randomUser];
                completion(randomUser, error);
                
            }
            
        } else {
            NSLog(@"Error Finding partners %@", error);
        }
    }];
}

/* Saves user profile picture after changing */

+(void)saveUserProfileImage:(UIImage *)image
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

+(void)saveUserLanguageSelection:(LMLanguageChoice)language forType:(LMLanguageChoiceType)type
{
    PFUser *user = [PFUser currentUser];
    
    if (type == LMLanguageChoiceTypeDesired) {
        user[PF_USER_DESIRED_LANGUAGE] = [LMGlobalVariables LMLanguageOptions][language];
    } else if (type == LMLanguageChoiceTypeFluent) {
        user[PF_USER_FLUENT_LANGUAGE] = [LMGlobalVariables LMLanguageOptions][language];
    }
    
    [user saveEventually];
}

+(void)saveUsersUsername:(NSString *)username
{
    PFUser *user = [PFUser currentUser];
    user[PF_USER_USERNAME] = username;
    user[PF_USER_USERNAME_LOWERCASE] = [username lowercaseString];
    [user saveEventually];
}

//-(void) sendChatRequestNotificationTo:(PFUser *)user withCompletion:(LMChatRequestResponseCompletion)
//{
//    PFQuery *queryInstallation = [PFInstallation query];
//    
//    NSDictionary *data = @{PF_CHAT_GROUPID : _groupId};
//    
//    [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:_chat[PF_CHAT_RECEIVER]];
//    
//    PFPush *push = [[PFPush alloc] init];
//    [push setQuery:queryInstallation];
//    //    [push setMessage:message[@"text"]];
//    [push setData:data];
//    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error)
//        {
//            NSLog(@"Error Sending Push");
//        }
//    }];
//}


@end

