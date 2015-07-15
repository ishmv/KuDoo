//
//  LMChatTableViewModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/12/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

@import UIKit;

typedef void (^LMPhotoDownloadCompletionBlock)(UIImage *image);

@class ChatsTableViewController;

@interface LMChatTableViewModel : NSObject

-(instancetype) initWithViewController:(UIViewController *)viewController;

@property (strong, nonatomic, readonly) ChatsTableViewController *viewController;

-(void) getImageForChat:(NSDictionary *)chat withCompletion:(LMPhotoDownloadCompletionBlock)completion;
-(NSMutableOrderedSet *) organizeChats:(NSOrderedSet *)chats;

@end
