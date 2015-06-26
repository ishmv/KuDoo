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
#import "NSDate+Chats.h"

#import <Firebase/Firebase.h>
#import <AFNetworking/AFNetworking.h>

@interface LMChatTableViewModel()

@property (strong, nonatomic, readwrite) ChatsTableViewController *viewController;
@property (strong, nonatomic, readwrite) NSMutableDictionary *chatThumbnails;
@property (strong, nonatomic, readwrite) NSMutableDictionary *messageCount;
@property (strong, nonatomic, readwrite) NSMutableDictionary *chatPictures;
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

-(void) getUserThumbnail:(NSString *)userId withCompletion:(LMPhotoDownloadCompletionBlock)completion
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
                    completion(image, error);
                }];
            });
        }];
    } else {
        completion(image, nil);
    }
}

-(void) getUserPicture:(NSString *)userId withCompletion:(LMPhotoDownloadCompletionBlock)completion
{
    UIImage *image = nil;
    
    image = [self.chatPictures objectForKey:userId];
    
    if (image == nil) {
        
        if (!_chatPictures) {
            self.chatPictures = [[NSMutableDictionary alloc] init];
        }
        
        [ParseConnection searchForUserIds:@[userId] withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            
            PFUser *user = [objects firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                ESTABLISH_WEAK_SELF;
                
                PFFile *imageFile = user[PF_USER_PICTURE];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    ESTABLISH_STRONG_SELF;
                    
                    UIImage *image = [UIImage imageWithData:data];
                    [strongSelf.chatPictures setObject:image forKey:user.objectId];
                    completion(image, error);
                }];
            });
        }];
    } else {
        completion(image, nil);
    }
}

-(void) getChatImage:(NSString *)urlString forGroupId:(NSString *)groupId withCompletion:(LMPhotoDownloadCompletionBlock)completion
{
    __block UIImage *image = nil;
    
    image = [self.chatPictures objectForKey:groupId];
    
    if (image == nil) {
        
        if (!_chatPictures) {
            self.chatPictures = [[NSMutableDictionary alloc] init];
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            ESTABLISH_WEAK_SELF;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ESTABLISH_STRONG_SELF;
                image = (UIImage *)responseObject;
                [strongSelf.chatPictures setObject:image forKey:groupId];
                completion(image, nil);
                
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to retreive chat image");
        }];
        
        [[NSOperationQueue mainQueue] addOperation:operation];
    } else {
        completion(image, nil);
    }
}

-(NSMutableOrderedSet *) organizeChats:(NSOrderedSet *)chats
{
    NSArray *sortedChats = [chats sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *chat1Id = obj1;
        NSString *chat2Id = obj2;
        
        NSDictionary *message1 = [_viewController.lastSentMessages objectForKey:chat1Id];
        NSDictionary *message2 = [_viewController.lastSentMessages objectForKey:chat2Id];
        
        NSString *date1String = message1[@"date"];
        NSString *date2String = message2[@"date"];
        
        NSDate *date1 = [NSDate lm_stringToDate:date1String];
        NSDate *date2 = [NSDate lm_stringToDate:date2String];
        
        NSTimeInterval timePassed = [date1 timeIntervalSinceDate:date2];
        
        if (timePassed > 0) {
            return NSOrderedAscending;
        }
        
        if (timePassed < 0){
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return [[NSMutableOrderedSet alloc] initWithArray:sortedChats];
    
}


#pragma mark - NSCoding

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.viewController = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(viewController))];
//        self.chatThumbnails = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(chatThumbnails))];
        self.messageCount = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messageCount))];
        
    } else {
        return nil;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.viewController forKey:NSStringFromSelector(@selector(viewController))];
//    [aCoder encodeObject:self.chatThumbnails forKey:NSStringFromSelector(@selector(chatThumbnails))];
    [aCoder encodeObject:self.messageCount forKey:NSStringFromSelector(@selector(messageCount))];
}

@end
