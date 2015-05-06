//
//  LMParseConnection.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/24/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMParseConnection.h"
#import "PushNotifications.h"
#import "AppConstant.h"
#import "LMChatFactory.h"

@implementation LMParseConnection

+(void) saveMessage:(PFObject *)message withCompletion:(LMFinishedUploadingMessageToServer)completion
{
//    PFObject *chat = message[PF_CHAT_CLASS_NAME];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
//        [chat pinInBackground];
        completion(succeeded, error);
        [LMParseConnection p_sendChatMembersMessage:message];
    }];
}

+(void) getMessagesForChat:(PFObject *)chat withCompletion:(LMFinishedFetchingChatMessages)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
    [query whereKey:PF_CHAT_CLASS_NAME equalTo:chat];
    [query orderByDescending:@"date"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array, error);
    }];
}

+(void) searchUsersWithCriteria:(NSDictionary *)critera withCompletion:(LMFinishedUserSearch)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    
    if (critera[PF_USER_USERNAME]) [query whereKey:PF_USER_USERNAME_LOWERCASE equalTo:critera[PF_USER_USERNAME]];
    else if (critera[PF_USER_DESIRED_LANGUAGE]) [query whereKey:PF_USER_DESIRED_LANGUAGE equalTo:critera[PF_USER_DESIRED_LANGUAGE]];
    else if (critera[PF_USER_FLUENT_LANGUAGE]) [query whereKey: PF_USER_FLUENT_LANGUAGE equalTo:critera[PF_USER_FLUENT_LANGUAGE]];
    
    [query setLimit:20];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        completion(users, error);
    }];
}

#pragma mark - Update User Profile Methods
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

#pragma mark - User Requests

+(void)sendUser:(PFUser *)user request:(LMRequestType)request withCompletion:(LMFinishedSendingRequestToUser)completion
{
    switch (request) {
        case LMRequestTypeFriend:
            [PushNotifications sendFriendRequestToUser:user];
            completion(YES, nil);
            break;
            
        default:
            break;
    }
}

#pragma mark - Helper Methods
/*
 
Migrate all code below to Parse Cloud Code 
 
*/
+(void) p_sendChatMembersMessage:(PFObject *)message
{
    PFObject *chat = message[PF_CHAT_CLASS_NAME];
    NSArray *chatMembers = [chat objectForKey:PF_CHAT_MEMBERS];
    NSString *groupId = message[PF_CHAT_GROUPID];
    
    for (PFUser *user in chatMembers) {
        PFQuery *chatQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [chatQuery whereKey:PF_CHAT_GROUPID equalTo:groupId];
        [chatQuery whereKey:PF_CHAT_SENDER equalTo:user];
        [chatQuery getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S retrievedChat,  NSError *PF_NULLABLE_S error)
         {
             if (retrievedChat) {
                 PFObject *newMessage = [LMParseConnection p_createCopyOfMessage:message];
                 [newMessage setObject:retrievedChat forKey:PF_CHAT_CLASS_NAME];
                 [newMessage saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
                     if (succeeded)
                     {
                         [PushNotifications sendNotificationToUser:user forMessage:newMessage];
                     }
                     else if (error)
                     {
                         NSLog(@"Unable to save chat members retrieved chat with updates, error:%@", error);
                     }
                 }];
             }
             
             else if (!retrievedChat && error.code == 101)
             {
                 [LMParseConnection p_createChat:chat forUser:user withMessage:message];
             }
             else if (error.code != 101)
             {
                 NSLog(@"Error retreiving user chat");
             }
         }];
    }
}

+(void) p_createChat:(PFObject *)chat forUser:(PFUser *)user withMessage:(PFObject *)message
{
    NSMutableArray *allChatMembers = [NSMutableArray arrayWithArray:[chat[PF_CHAT_MEMBERS] copy]];
    [allChatMembers addObject:chat[PF_CHAT_SENDER]];
    
    [LMChatFactory createChatForUser:user withMembers:allChatMembers chatDetails:@{} andCompletion:^(PFObject *newChat, NSError *error) {
        PFObject *newMessage = [LMParseConnection p_createCopyOfMessage:message];
        [newMessage setObject:newChat forKey:PF_CHAT_CLASS_NAME];
        
        if (allChatMembers.count > 2)
        {
            newChat[PF_CHAT_TITLE] = chat[PF_CHAT_TITLE];
            newChat[PF_CHAT_PICTURE] = chat[PF_CHAT_PICTURE];
        }
        
        [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [PushNotifications sendNotificationToUser:user forMessage:newMessage];
            }
            else if (error)
            {
                NSLog(@"Unable to save newly created chat, error:%@", error);
            }
        }];
    }];
}

+(PFObject *) p_createCopyOfMessage:(PFObject *)message
{
    PFObject *messageCopy = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];

    messageCopy[PF_MESSAGE_USER] = message[PF_MESSAGE_USER];
    messageCopy[PF_MESSAGE_SENDER_NAME] = [message[PF_MESSAGE_SENDER_NAME] copy];
    messageCopy[PF_MESSAGE_GROUPID] = [message[PF_MESSAGE_GROUPID] copy];
    messageCopy[PF_MESSAGE_SENDER_ID] = [message[PF_MESSAGE_SENDER_ID] copy];
    
    if (message[PF_MESSAGE_IMAGE])
    {
        messageCopy[PF_MESSAGE_IMAGE] = message[PF_MESSAGE_IMAGE];
    }
    else if (message[PF_MESSAGE_TEXT])
    {
        messageCopy[PF_MESSAGE_TEXT] = [message[PF_MESSAGE_TEXT] copy];
    }
    else if (message[PF_MESSAGE_AUDIO])
    {
        messageCopy[PF_MESSAGE_AUDIO] = message[PF_MESSAGE_AUDIO];
    }
    else if (message[PF_MESSAGE_VIDEO])
    {
        messageCopy[PF_MESSAGE_VIDEO] = message[PF_MESSAGE_VIDEO];
    }
    
    return messageCopy;
}

@end
