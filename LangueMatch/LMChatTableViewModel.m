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

-(void) getChatImage:(NSString *)urlString withCompletion:(LMPhotoDownloadCompletionBlock)completion
{
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = (UIImage *)responseObject;
            completion(image, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIImage *defaultImage = [UIImage imageNamed:@"connected"];
            completion(defaultImage, error);
        }];
        
        [[NSOperationQueue mainQueue] addOperation:operation];
    } else {
        UIImage *defaultImage = [UIImage imageNamed:@"connected"];
        completion(defaultImage, nil);
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
        self.messageCount = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messageCount))];
        self.chatThumbnails = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(viewController))];
        
    } else {
        return nil;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.viewController forKey:NSStringFromSelector(@selector(viewController))];
    [aCoder encodeObject:self.messageCount forKey:NSStringFromSelector(@selector(messageCount))];
    [aCoder encodeObject:self.chatThumbnails forKey:NSStringFromSelector(@selector(chatThumbnails))];
}

@end
