//
//  ViewController.h
//  simplechat
//
//  Created by Travis Buttaccio on 5/28/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

@interface ViewController : JSQMessagesViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/*
 
 Designated initializer. Setting archiveMessages to YES will save all messages to disk when chat room window disappears
 
 */
-(instancetype) initWithGroupId:(NSString *)groupId archiveMessages:(BOOL)archiveMessages;

/*
 
 Initializer sets archiveMessages to NO on designated initializer
 
 */
-(instancetype) initWithGroupId:(NSString *)groupId;

@end

