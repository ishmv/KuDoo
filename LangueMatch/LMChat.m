#import "LMChat.h"
#import "AppConstant.h"
#import "LMData.h"
#import "LMChatsModel.h"

#import <Parse/Parse.h>

@interface LMChat()

@end

typedef void (^LMFindRandomUserCompletion)(PFUser *user, NSError *error);

@implementation LMChat

-(instancetype) init
{
    if (self = [super init]) {
       
    }
    return self;
}

/* 
 
 Initiates an isolated chat
 Chat will be deleted from server once complete;
 
 */

+(void) startRandomChatWithCompletion:(LMInitiateChatCompletionBlock)completion
{
    [LMChat findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
        if (error != nil) {
            completion(nil, error);
        } else {
            PFUser *user1 = [PFUser currentUser];
            PFUser *user2 = user;
            
            NSDictionary *chatOptions = @{PF_CHAT_RANDOM : @YES};
            
            PFObject *chat = [LMChat createChatWithUsers:[NSArray arrayWithObjects:user1, user2, nil] withOptions:chatOptions];
            
            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     completion(chat, error);
                 }
                 else
                 {
                     completion(nil, error);
                 }
             }];
        }
    }];
}

#pragma mark - Helper Method

+(PFObject *) createChatWithUsers:(NSArray *)users withOptions:(NSDictionary *)options
{
    /* -- Order users to create unique groupId -- */
    
    NSArray *orderedUsers = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PFUser *user1 = (PFUser *)obj1;
        PFUser *user2 = (PFUser *)obj2;
        
        NSString *id1 = user1.objectId;
        NSString *id2 = user2.objectId;
        
        if ([id1 compare:id2] < 0) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([id1 compare:id2] > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableString *groupId = [NSMutableString new];
    
    for (PFUser *user in orderedUsers) {
        [groupId appendString:user.objectId];
    }
    
    
    PFObject *currentUserChat;
    
    /* Check if two person chat - use for chat title and picture */
    PFUser *currentUser;
    PFUser *receivingUser;
    
    if (orderedUsers.count == 2) {
        for (PFUser *user in orderedUsers) {
            if (user == [PFUser currentUser]) {
                currentUser = user;
            } else {
                receivingUser = user;
            }
        }
    }
    
    /* -- Check if chat already exists in local datastore -- */
    
    PFQuery *queryChats = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [queryChats fromLocalDatastore];
    [queryChats whereKey:PF_CHAT_GROUPID equalTo: groupId];
    PFObject *chat = [queryChats getFirstObject];
    
    if (chat) {
        return chat;
    } else {
        
        for (PFUser *user in orderedUsers) {
            PFObject *chat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
            chat[PF_CHAT_GROUPID] = groupId;
            chat[PF_CHAT_SENDER] = user;
            
            if (orderedUsers.count == 2) {
                if (user == currentUser) {
                    chat[PF_CHAT_TITLE] = receivingUser.username;
                    chat[PF_CHAT_PICTURE] = receivingUser[PF_USER_PICTURE];
                } else {
                    chat[PF_CHAT_TITLE] = currentUser.username;
                    chat[PF_CHAT_PICTURE] = currentUser[PF_USER_PICTURE];
                }
            } else {
                chat[PF_CHAT_TITLE] = [options objectForKey:PF_CHAT_TITLE];
                chat[PF_CHAT_PICTURE] = [options objectForKey:PF_CHAT_PICTURE];
            }
            
            chat[PF_CHAT_MEMBERS] = orderedUsers;
            chat[PF_MESSAGES_COUNTER] = @0;
            
            if ([options objectForKey:@"random"]) {
                chat[PF_CHAT_RANDOM] = @YES;
            }
            
            if (user == [PFUser currentUser]) {
                currentUserChat = chat;
                [chat pinInBackground];
                [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [chat pin];
                }];
            } else {
                [chat saveInBackground];
            }
        }
    }
    return currentUserChat;
}

/*
 
 Initiate chat with passed in friends list
 
 */

+(void) startChatWithFriends:(NSArray *)friends withChatOptions:(NSDictionary *)options withCompletion:(LMInitiateChatCompletionBlock)completion
{
    UIImage *chatImage = options[PF_CHAT_PICTURE];
    NSData *imageData = UIImageJPEGRepresentation(chatImage, 0.9);
    PFFile *imageFile = [PFFile fileWithName:PF_CHAT_PICTURE data:imageData];
    
    NSString *chatTitle = options[PF_CHAT_TITLE];
    
    NSDictionary *dictionaryWithConvertedImage = @{PF_CHAT_TITLE: chatTitle, PF_CHAT_PICTURE : imageFile};
    
    NSMutableArray *friendsWithCurrentUser = [friends mutableCopy];
    [friendsWithCurrentUser addObject:[PFUser currentUser]];
    
    PFObject *chat = [LMChat createChatWithUsers:friendsWithCurrentUser withOptions:dictionaryWithConvertedImage];
    
    completion (chat, nil);
}

#pragma mark - Find Random User

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



@end
