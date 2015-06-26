//
//  LMChatTableViewModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/12/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMPhotoDownloadCompletionBlock)(UIImage *image, NSError *error);

@class ChatsTableViewController, FDataSnapshot, Firebase, LMTableViewCell;

@interface LMChatTableViewModel : NSObject <NSCoding>

-(instancetype) initWithViewController:(UIViewController *)viewController;

@property (strong, nonatomic, readonly) ChatsTableViewController *viewController;
@property (strong, nonatomic, readonly) Firebase *firebase;

-(void) getUserThumbnail:(NSString *)userId withCompletion:(LMPhotoDownloadCompletionBlock)completion;
-(void) getUserPicture:(NSString *)userId withCompletion:(LMPhotoDownloadCompletionBlock)completion;
-(void) getChatImage:(NSString *)urlString forGroupId:(NSString *)groupId withCompletion:(LMPhotoDownloadCompletionBlock)completion;

-(NSMutableOrderedSet *) organizeChats:(NSOrderedSet *)chats;

-(void) setupFirebaseWithAddress:(NSString *)path forUser:(NSString *)userId;

@end
