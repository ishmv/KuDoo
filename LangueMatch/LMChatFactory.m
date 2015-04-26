#import "LMChatFactory.h"
#import "AppConstant.h"
#import "LMData.h"
#import "LMChatsModel.h"

#import <Parse/Parse.h>

@interface LMChatFactory()

@end

typedef void (^LMFindRandomUserCompletion)(PFUser *user, NSError *error);

@implementation LMChatFactory

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
    [LMChatFactory findRandomUserForChatWithCompletion:^(PFUser *user, NSError *error) {
        if (error != nil) {
            completion(nil, error);
        } else {
//            PFUser *user1 = [PFUser currentUser];
//            PFUser *user2 = user;
//            
//            NSDictionary *chatOptions = @{PF_CHAT_RANDOM : @YES};
//
//            [LMChatFactory createChatWithUsers:[NSArray arrayWithObjects:user1, user2, nil] withOptions:chatOptions withCompletion:^(PFObject *chat, NSError *error) {
//                completion(chat, error);
//            }];
//
//            [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//             {
//                 if (!error)
//                 {
//                     completion(chat, error);
//                 }
//                 else
//                 {
//                     completion(nil, error);
//                 }
//             }];
        }
    }];
}


+(void) createChatForUser:(PFUser *)user withMembers:(NSArray *)members chatDetails:(NSDictionary *)details andCompletion:(LMFinishedCreatingChatCompletionBlock)completion
{
    NSMutableArray *allChatMembers = [NSMutableArray array];
    NSMutableArray *receivingChatMembers = [NSMutableArray array];
    
    if ([members containsObject:user]) {
        allChatMembers = [members copy];
        receivingChatMembers = [members mutableCopy];
        [receivingChatMembers removeObject:user];
    } else {
        allChatMembers = [members mutableCopy];
        [allChatMembers addObject:user];
        receivingChatMembers = [members copy];
    }
    
    NSString *groupId = [LMChatFactory p_createChatGroupIdFromUsers:allChatMembers];
    
    PFQuery *queryChats = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [queryChats fromLocalDatastore];
    [queryChats whereKey:PF_CHAT_GROUPID equalTo: groupId];
    [queryChats whereKey:PF_CHAT_SENDER equalTo:user];
    [queryChats getFirstObjectInBackgroundWithBlock:^(PFObject *chat, NSError *error)
     {
         if (chat && !error)
         {
             completion(chat, error);
         }
         else
         {
             PFUser *currentUser = user;
             
             PFObject *newChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
             newChat[PF_CHAT_GROUPID] = groupId;
             newChat[PF_CHAT_SENDER] = currentUser;
             newChat[PF_CHAT_MEMBERS] = receivingChatMembers;
             newChat[PF_MESSAGE_COUNTER] = @0;
             
             if (allChatMembers.count == 2)
             {
                 PFUser *receivingUser = receivingChatMembers[0];
                 newChat[PF_CHAT_TITLE] = receivingUser.username;
                 newChat[PF_CHAT_PICTURE] = receivingUser[PF_USER_PICTURE];
             }
             
             else if (allChatMembers.count > 2)
             {
                 UIImage *chatImage = details[PF_CHAT_PICTURE];
                 NSData *imageData = UIImageJPEGRepresentation(chatImage, 0.9);
                 PFFile *imageFile = [PFFile fileWithName:PF_CHAT_PICTURE data:imageData];
                 
                 newChat[PF_CHAT_TITLE] = [details[PF_CHAT_TITLE] copy];
                 newChat[PF_CHAT_PICTURE] = imageFile;
             }
             
             if ([details objectForKey:@"random"])
             {
                 newChat[PF_CHAT_RANDOM] = @YES;
             }
             completion(newChat, nil);
         }
     }];
}

#pragma mark - Helper Method

+(NSString *) p_createChatGroupIdFromUsers:(NSArray *)users
{
    NSArray *orderedUsers = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PFUser *user1 = (PFUser *)obj1;
        PFUser *user2 = (PFUser *)obj2;
        
        NSString *id1 = user1.objectId;
        NSString *id2 = user2.objectId;
        
        if ([id1 compare:id2] < 0)
        {
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
    
    return groupId;
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
