#import <Foundation/Foundation.h>

@class PFObject, JSQMessage;

typedef NS_ENUM(NSInteger, LMMessageType) {
    LMMessageTypeText    = 1,
    LMMessageTypeImage   = 2,
    LMMessageTypeVideo   = 3,
    LMMessageTypeAudio   = 4
};

@interface LMMessageFactory : NSObject

/*
 
 @abstract: Helper method to create local LMMessage ready to send to Parse
 
 @param: Type - indicates the type of the message
         Details - detailed information regarding the message (senderId, timestamp, media, senderName)
 
 Discussion: This is primarily to reduce the size of the Chat View Controller where much of the content is used in preparing messages
 
 @returns: Returns a local LMMessage (PFObject[PF_MESSAGE_CLASSNAME]);
 
 */
+(PFObject *) createMessageType:(LMMessageType)type withDetails:(NSDictionary *)details;

+(JSQMessage *)createJSQMessageFromLMMessage:(PFObject *)message;

@end
