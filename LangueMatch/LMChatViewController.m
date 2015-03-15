#import "LMChatViewController.h"
#import "LMChat.h"
#import "LMMessage.h"
#import <Parse/Parse.h>
#import "AppConstant.h"

@interface LMChatViewController ()

@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) LMChat *chat;

@end

@implementation LMChatViewController

-(instancetype) initWithUsers:(NSArray *)users
{
    if (self = [super init]) {
        
        
        self.users = users;
        [self initializeChat];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser].username;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    LMMessage *message = [LMMessage new];
    
    message.text = text;
    message.sender = [PFUser currentUser];
    
    PFObject *newMessage = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
    newMessage[PF_MESSAGES_USER] = senderDisplayName;
    
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"sent!");
        } else {
            //ToDo Error Message
        }
    }];
    
    [self finishSendingMessage];
}

-(void)initializeChat
{
    PFObject *newChat = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    newChat[PF_CHAT_MEMBERS] = self.users;
    
    [newChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Started New Chat");
        }
    }];
}


@end
