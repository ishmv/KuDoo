//
//  LMForumChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMForumChatViewController.h"
#import "NSArray+LanguageOptions.h"

@interface LMForumChatViewController ()

@property (strong, nonatomic) UIImageView *chatImageView;

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
}

#pragma mark - Setter Methods


@end
