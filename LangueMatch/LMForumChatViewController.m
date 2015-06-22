//
//  LMForumChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMForumChatViewController.h"
#import "NSArray+LanguageOptions.h"
#import "LMOnlineUserProfileViewController.h"

#import "ParseConnection.h"

@interface LMForumChatViewController ()

@property (strong, nonatomic) UIImageView *chatImageView;
@property (strong, nonatomic) NSMutableDictionary *profileVCs;

@end

@implementation LMForumChatViewController

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId
{
    if (self = [super initWithFirebaseAddress:address andGroupId:groupId]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!_chatImageView) {
        
        __block NSInteger flagIndex = 0;
        
        [[NSArray lm_languageOptionsNative] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *language = (NSString *)obj;
            
            if ([language isEqualToString:self.groupId]) {
                flagIndex = idx;
                *stop = YES;
            }
        }];
        
        UIImage *flagImage = [NSArray lm_countryFlagImages][flagIndex];
        self.chatImageView = [[UIImageView alloc] initWithImage:flagImage];
        self.chatImageView.frame = CGRectMake(0, 0, 44, 44);
        self.chatImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIBarButtonItem *chatImage = [[UIBarButtonItem alloc] initWithCustomView:self.chatImageView];
        [self.navigationItem setRightBarButtonItem:chatImage];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.profileVCs = nil;
}

#pragma mark - JSQMessagesCollectionView Delegate

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_profileVCs) {
        self.profileVCs = [[NSMutableDictionary alloc] init];
    }
    
    __block LMOnlineUserProfileViewController *userVC = self.profileVCs[senderId];
    
    if (userVC == nil) {
        [ParseConnection searchForUserIds:@[senderId] withCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            PFUser *user = [objects firstObject];
            userVC = [[LMOnlineUserProfileViewController alloc] initWithUser:user];
            [self.profileVCs setValue:userVC forKey:senderId];
            [self presentViewController:userVC animated:YES completion:nil];
        }];
    } else {
        [self presentViewController:userVC animated:YES completion:nil];
    }
}


@end
