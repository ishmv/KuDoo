/*
 
 List of chats for user
 
 */

#import <Foundation/Foundation.h>

@class PFObject;

@interface LMChatsModel : NSObject

@property (strong, nonatomic, readonly) NSArray *chatList;

-(void) deleteChat:(PFObject *)chat;
-(void) addChat:(PFObject *)chat;

@end
