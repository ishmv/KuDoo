/*
 
 List of active chats for the user
 Uses KVO to communicate changes on chatList
 
 */

#import <Foundation/Foundation.h>

@class PFObject;

@interface LMChatsModel : NSObject

@property (strong, nonatomic, readonly) NSArray *chatList;

-(void) deleteChat:(PFObject *)chat;
-(void) addChat:(PFObject *)chat;

@end
