//
//  LMParseConnection.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/24/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMParseConnection.h"
#import "AppConstant.h"
#import "LMGlobalVariables.h"

@implementation LMParseConnection

+(void) signupUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion
{
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completion(succeeded, error);
    }];
}

+(void) loginUser:(NSString *)username withPassword:(NSString *)password withCompletion:(LMFinishedLoggingInUser)completion
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        completion(user, error);
    }];
}

+(void)saveUserImage:(UIImage *)image forType:(LMUserPicture)pictureType
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
    
    if (pictureType == LMUserPictureSelf) {
        user[@"picture"] = imageFile;
        user[@"thumbnail"] = thumbnailFile;
    } else {
        user[@"backgroundPicture"] = imageFile;
        user[@"backgroundPictureThumbnail"] = thumbnailFile;
    }
    
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


@end
