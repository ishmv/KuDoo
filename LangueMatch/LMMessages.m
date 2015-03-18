#import "LMMessages.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMMessages() {
    NSMutableArray *_messages;
}

@property (nonatomic, strong) NSArray *messages;

@end

@implementation LMMessages

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)setGroupID:(NSString *)groupID
{
    _groupID = groupID;
    
    [self getMessagesForChat];
}

-(void)getMessagesForChat
{
    //Fix to only search current chat
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:@"groupId" equalTo:self.groupID];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.messages = objects;
    }];
}


-(void)sendMessage:(PFObject *)message
{
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved Message");
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"messages"];
            [mutableArrayWithKVO addObject:message];
        }
    }];
}

-(void) loadMessages
{
    [self getMessagesForChat];
}

#pragma mark - KVO Methods

-(NSUInteger) countOfMessages
{
    return self.messages.count;
}

-(id) objectInMessagesAtIndex:(NSUInteger)index
{
    return [self.messages objectAtIndex:index];
}

-(NSArray *) messagesAtIndexes:(NSIndexSet *)indexes
{
    return [self.messages objectsAtIndexes:indexes];
}

-(void) insertObject:(PFObject *)object inMessagesAtIndex:(NSUInteger)index
{
    [_messages insertObject:object atIndex:index];
}

-(void) removeObjectFromMessagesAtIndex:(NSUInteger)index
{
    [_messages removeObjectAtIndex:index];
}

-(void) replaceObjectInMessagesAtIndex:(NSUInteger)index withObject:(id)object
{
    [_messages replaceObjectAtIndex:index withObject:object];
}

@end