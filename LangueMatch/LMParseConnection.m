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
        [PushNotifications sendMessageNotificationForChat:chat];
    }];
    
    if (!chat.objectId) {
        [LMParseConnection p_createMemberChatsFromChat:chat];
    } else {
        [LMParseConnection p_updateChatMessagesForChat:chat];
    }
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
            [newChat saveInBackground];
        }];
    }    
}

+(void) p_updateChatMessagesForChat:(PFObject *)chat
{
    PFQuery *chatQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    NSArray *chatMembers = [chat[PF_CHAT_MEMBERS] copy];
    
    for (PFUser *user in chatMembers) {
        [chatQuery whereKey:PF_CHAT_SENDER equalTo:user];
        [chatQuery getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S retrievedChat,  NSError *PF_NULLABLE_S error){
            [retrievedChat[PF_CHAT_MESSAGES] addObject:chat[PF_CHAT_LASTMESSAGE]];
            retrievedChat[PF_CHAT_LASTMESSAGE] = chat[PF_CHAT_LASTMESSAGE];
            [retrievedChat incrementKey:PF_CHAT_MESSAGECOUNT];
            [retrievedChat saveInBackground];
        }];
    }
}

@end
