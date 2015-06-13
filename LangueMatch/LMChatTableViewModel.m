//
//  LMChatTableViewModel.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/12/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatTableViewModel.h"
#import "ChatsTableViewController.h"
#import "ParseConnection.h"
#import "AppConstant.h"
#import "Utility.h"

#import <Firebase/Firebase.h>

@interface LMChatTableViewModel()

@property (strong, nonatomic, readwrite) ChatsTableViewController *viewController;
@property (strong, nonatomic, readwrite) NSMutableDictionary *lastMessages;
@property (strong, nonatomic, readwrite) NSMutableDictionary *chatThumbnails;
@property (strong, nonatomic, readwrite) NSMutableDictionary *messageCount;
@property (strong, nonatomic, readwrite) Firebase *firebase;

@end

@implementation LMChatTableViewModel

-(instancetype) initWithViewController:(ChatsTableViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

-(void) setupFirebaseWithAddress:(NSString *)path forUser:(NSString *)userId {
    self.firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat: @"%@/users/%@/chats", path, userId]];
    
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.viewController updateChatsWithSnapshot:snapshot];
    }];
}

-(UIImage *) getUserThumbnail:(NSString *)userId
{
    UIImage *image = nil;
    
    image = [self.chatThumbnails objectForKey:userId];
    
    if (image == nil) {
        
        if (!_chatThumbnails) {
            self.chatThumbnails = [[NSMutableDictionary alloc] init];
        }
        
        [ParseConnection searchForUserIds:@[userId] withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            
            PFUser *user = [objects firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                ESTABLISH_WEAK_SELF;
                
                PFFile *imageFile = user[PF_USER_THUMBNAIL];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    ESTABLISH_STRONG_SELF;
                    
                    UIImage *image = [UIImage imageWithData:data];
                    [strongSelf.chatThumbnails setObject:image forKey:user.objectId];
                    [self.viewController.tableView reloadData];
                }];
            });
        }];
    }
    return image;
}

-(NSMutableOrderedSet *) organizeChats:(NSOrderedSet *)chats
{
    NSArray *sortedChats = [chats sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *chat1Id = obj1;
        NSString *chat2Id = obj2;
        
        NSDictionary *message1 = [self.lastMessages objectForKey:chat1Id];
        NSDictionary *message2 = [self.lastMessages objectForKey:chat2Id];
        
        NSDate *date1 = message1[@"date"];
        NSDate *date2 = message2[@"date"];
        
        if (date1 > date2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (date1 < date2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return [[NSMutableOrderedSet alloc] initWithArray:sortedChats];
    
}

@end
