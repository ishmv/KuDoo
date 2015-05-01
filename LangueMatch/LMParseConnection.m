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
    PFObject *chat = message[PF_CHAT_CLASS_NAME];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [chat pinInBackground];
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

#pragma mark - Helper Methods
/*
 
Migrate to Parse Cloud Code
 
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
    
    return messageCopy;
}

@end
