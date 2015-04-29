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

+(void) saveChat:(PFObject *)chat withCompletion:(LMFinishedUploadingChatToServer)completion
{
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        completion(succeeded, error);
        [chat pinInBackground]; //Needed?
        [LMParseConnection p_updateChatMessagesForChat:chat];
    }];
}

+(void) p_createMemberChatsFromChat:(PFObject *)chat
{
    NSMutableArray *allChatMembers = [NSMutableArray arrayWithArray:[chat[PF_CHAT_MEMBERS] copy]];
    [allChatMembers addObject:chat[PF_CHAT_SENDER]];
    NSArray *chatMembers = [chat[PF_CHAT_MEMBERS] copy];
    
    NSDictionary *chatDetails = @{};
    
    if (allChatMembers.count > 2)
    {
        NSArray *chatTitle = chat[PF_CHAT_TITLE];
        PFFile *chatPicture = chat[PF_CHAT_PICTURE];
        chatDetails = @{PF_CHAT_TITLE : chatTitle, PF_CHAT_PICTURE : chatPicture};
    }
    
    for (PFUser *user in chatMembers) {
        [LMChatFactory createChatForUser:user withMembers:allChatMembers chatDetails:chatDetails andCompletion:^(PFObject *newChat, NSError *error) {
            newChat[PF_CHAT_MESSAGES] = chat[PF_CHAT_MESSAGES];
            newChat[PF_CHAT_MESSAGECOUNT] = chat[PF_CHAT_MESSAGECOUNT];
            newChat[PF_CHAT_LASTMESSAGE] = chat[PF_CHAT_LASTMESSAGE];
            [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [PushNotifications sendMessageNotificationToUser:user forChat:newChat];
                }
                else if (error)
                {
                    NSLog(@"%@", error);
                }
            }];
        }];
    }
}

+(void) createMemberChatFromGroupId:(NSString *)groupId senderId:(NSString *)senderId withCompletion:(LMFinishedCreatingChatCompletionBlock)completion
{
    PFQuery *chatQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [chatQuery whereKey:PF_CHAT_GROUPID equalTo:groupId];
    [chatQuery whereKey:PF_CHAT_SENDER_ID equalTo:senderId];
    [chatQuery includeKey:PF_CHAT_MEMBERS];
    [chatQuery includeKey:PF_CHAT_SENDER];
    [chatQuery includeKey:PF_CHAT_LASTMESSAGE];
    
    [chatQuery getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error) {
        if (!error) {
            
            NSMutableArray *allChatMembers = [NSMutableArray arrayWithArray:[chat[PF_CHAT_MEMBERS] copy]];
            [allChatMembers addObject:chat[PF_CHAT_SENDER]];
            
            [LMChatFactory createChatForUser:[PFUser currentUser] withMembers:allChatMembers chatDetails:@{} andCompletion:^(PFObject *newChat, NSError *error) {
                [newChat addObject:chat[PF_CHAT_LASTMESSAGE] forKey:PF_CHAT_MESSAGES];
                newChat[PF_CHAT_MESSAGECOUNT] = @1;
                newChat[PF_CHAT_LASTMESSAGE] = chat[PF_CHAT_LASTMESSAGE];
                
                if (allChatMembers.count > 2) {
                    newChat[PF_CHAT_TITLE] = chat[PF_CHAT_TITLE];
                    newChat[PF_CHAT_PICTURE] = chat[PF_CHAT_PICTURE];
                }
                
                [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        [newChat pinInBackground];
                        completion(newChat, error);
                    }
                    else if (error)
                    {
                        NSLog(@"%@", error);
                    }
                }];
            }];
        }
    }];
}

//Move to Parse Cloud Code

+(void) p_updateChatMessagesForChat:(PFObject *)chat
{
    NSString *groupId = [chat[PF_CHAT_GROUPID] copy];
    NSArray *chatMembers = [chat[PF_CHAT_MEMBERS] copy];
    PFObject *newMessage = chat[PF_CHAT_LASTMESSAGE];
    
    PFQuery *chatQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [chatQuery whereKey:PF_CHAT_GROUPID equalTo:groupId];
    
    for (PFUser *user in chatMembers) {
        [chatQuery whereKey:PF_CHAT_SENDER_ID equalTo:user.objectId];
        [chatQuery getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S retrievedChat,  NSError *PF_NULLABLE_S error){
            
            if (retrievedChat) {
                [retrievedChat addObject:newMessage forKey:PF_CHAT_MESSAGES];
                retrievedChat[PF_CHAT_LASTMESSAGE] = newMessage;
                [retrievedChat incrementKey:PF_CHAT_MESSAGECOUNT];
                [retrievedChat saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        [PushNotifications sendMessageNotificationToUser:user forChat:retrievedChat];
                    }
                    else if (error)
                    {
                        NSLog(@"Unable to save chat members retrieved chat with updates, error:%@", error);
                    }
                }];
            }
            
            else if (!retrievedChat && error.code == 101)
            {
                [LMParseConnection p_createChat:chat forUser:user];
            }
            else if (error.code != 101)
            {
                NSLog(@"Error retreiving user chat");
            }
        }];
    }
}


+(void) p_createChat:(PFObject *)chat forUser:(PFUser *)user
{
    NSMutableArray *allChatMembers = [NSMutableArray arrayWithArray:[chat[PF_CHAT_MEMBERS] copy]];
    [allChatMembers addObject:chat[PF_CHAT_SENDER]];
    
    [LMChatFactory createChatForUser:user withMembers:allChatMembers chatDetails:@{} andCompletion:^(PFObject *newChat, NSError *error) {
        [newChat addObject:chat[PF_CHAT_LASTMESSAGE] forKey:PF_CHAT_MESSAGES];
        newChat[PF_CHAT_MESSAGECOUNT] = @1;
        newChat[PF_CHAT_LASTMESSAGE] = chat[PF_CHAT_LASTMESSAGE];
        
        if (allChatMembers.count > 2)
        {
            newChat[PF_CHAT_TITLE] = chat[PF_CHAT_TITLE];
            newChat[PF_CHAT_PICTURE] = chat[PF_CHAT_PICTURE];
        }
        
        [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [PushNotifications sendMessageNotificationToUser:user forChat:newChat];
            }
            else if (error)
            {
                NSLog(@"Unable to save newly created chat, error:%@", error);
            }
        }];
    }];
}

@end
