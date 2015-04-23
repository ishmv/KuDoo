#import "LMData.h"
#import "AppConstant.h"

@interface LMData()

@property (strong, nonatomic) NSMutableArray *dummyMessages;

@end

@implementation LMData

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init
{
    if (self = [super init]) {
        [self createDummyMessages];
    }
    return self;
}

-(void) createDummyMessages
{
    _dummyMessages = [NSMutableArray array];
    
    NSArray *randomResponses = @[@"hey", @"whats up", @"This is crazy", @"Im freaking out man", @"Monkeys all over", @"Obama who?", @"Testing", @"whazzzzzzzup"];
    
    for (int i = 0; i < randomResponses.count; i++) {
        PFObject *message = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
        
        //        message[PF_MESSAGE_USER] = currentUser;
        message[PF_MESSAGE_TEXT] = randomResponses[i];
        message[PF_MESSAGE_SENDER_NAME] = @"travis";
        message[PF_MESSAGE_GROUPID] = @"groupId";
        message[PF_MESSAGE_SENDER_ID] = @"travis";
        message[PF_MESSAGE_TIMESENT] = [NSDate date];
        
        [_dummyMessages addObject:message];
    }
    
    PFObject *mediaMessage = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    mediaMessage[PF_MESSAGE_IMAGE] = [PFFile fileWithData:imageData];
    mediaMessage[PF_MESSAGE_SENDER_NAME] = @"travis";
    mediaMessage[PF_MESSAGE_GROUPID] = @"groupId";
    mediaMessage[PF_MESSAGE_SENDER_ID] = @"travis";
    mediaMessage[PF_MESSAGE_TIMESENT] = [NSDate date];
    
    [_dummyMessages addObject:mediaMessage];
}


-(PFObject *)receiveMessage
{
    int random = arc4random_uniform((int)_dummyMessages.count);
    return _dummyMessages[random];
}

@end
