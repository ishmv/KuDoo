//
//  LMChatTableViewModel.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/12/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatsTableViewController, FDataSnapshot, Firebase, LMTableViewCell;

@interface LMChatTableViewModel : NSObject

-(instancetype) initWithViewController:(UIViewController *)viewController;

@property (strong, nonatomic, readonly) ChatsTableViewController *viewController;
@property (strong, nonatomic, readonly) Firebase *firebase;

-(UIImage *) getUserThumbnail:(NSString *)userId;
-(NSMutableOrderedSet *) organizeChats:(NSOrderedSet *)chats;

-(void) setupFirebaseWithAddress:(NSString *)path forUser:(NSString *)userId;

@end
