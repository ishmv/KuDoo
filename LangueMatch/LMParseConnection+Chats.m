//
//  LMParseConnection+Chats.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMParseConnection+Chats.h"
#import "AppConstant.h"
#import "LMChatFactory.h"
#import "PushNotifications.h"
#import "LMFriendsModel.h"

@implementation LMParseConnection (Chats)

+(void) saveMessage:(PFObject *)message withCompletion:(LMFinishedUploadingMessageToServer)completion
{
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         completion(succeeded, error);
         [LMParseConnection p_sendChatMembersMessage:message];
     }];
}

+(void) getMessagesForChat:(PFObject *)chat fromDatasStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
    [query whereKey:PF_CHAT_CLASS_NAME equalTo:chat];
    [query orderByAscending:@"createdAt"];
    
    if (fromDatastore)
    {
        [query fromLocalDatastore];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        completion(array, error);
    }];
}


+(void) getChatsFromLocalDataStore:(BOOL)fromDatastore withCompletion:(LMFinishedFetchingObjects)completion
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *queryChat = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [queryChat whereKey:PF_CHAT_SENDER equalTo:currentUser];
    [queryChat includeKey:PF_CHAT_MEMBERS];
    [queryChat setLimit:50];
    
    if (fromDatastore)
    {
        [queryChat fromLocalDatastore];
        [queryChat findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
            completion(chats, error);
        }];
    }
    else
    {
        [queryChat findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
            
            NSMutableArray *nonRandomChats = [NSMutableArray new];
            
            for (PFObject *chat in chats)
            {
                if (!chat[PF_CHAT_RANDOM]) {
                    [nonRandomChats addObject:chat];
                } else {
                    [chat deleteEventually];
                }
            }
            
            completion(chats, error);
        }];
    }
}

+(void)findRandomUserForChatWithCompletion:(LMFindRandomUserCompletion)completion
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *desiredLanguage = currentUser[PF_USER_DESIRED_LANGUAGE];
    NSString *fluentLanguage = currentUser[PF_USER_FLUENT_LANGUAGE];
    
    NSArray *friendList = [[LMFriendsModel sharedInstance] friendList];
    NSMutableArray *friendIds = [NSMutableArray array];
    
    //Exclude current user from search
    [friendIds addObject:currentUser.objectId];
    
    //Get friends object Ids to query against
    for (PFUser *friend in friendList) {
        [friendIds addObject:friend.objectId];
    }
    
    // if user base grows will need to change algorithm to query count number of objects first then choose one at random
    
    PFQuery *randomQuery = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [randomQuery whereKey:PF_USER_FLUENT_LANGUAGE equalTo:desiredLanguage];
    [randomQuery whereKey:PF_USER_DESIRED_LANGUAGE equalTo:fluentLanguage];
    [randomQuery whereKey:PF_USER_OBJECTID notContainedIn:friendIds];
    [randomQuery whereKey:PF_USER_AVAILABILITY equalTo:@(YES)];
    [randomQuery setLimit:100];
    
    [randomQuery findObjectsInBackgroundWithBlock:^(NSArray *matches, NSError *retrievalError) {
        
        if (matches) {
            
            int matchCount = (int)matches.count;
            
            if (matchCount) {
                NSUInteger randomSelection = arc4random_uniform(matchCount);
                PFUser *randomUser = matches[randomSelection];
                
                PFFile *userThumbnail = randomUser[PF_USER_THUMBNAIL];
                [userThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                    if (!error)
                    {
                        UIImage *userImage = [UIImage imageWithData:imageData];
                        completion(randomUser, userImage, retrievalError);
                    }
                }];
                
            }
        }
    }];
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
