//
//  LMChatViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 6/8/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatViewController.h"
#import "UIFont+ApplicationFonts.h"
#import "NSString+Chats.h"
#import "NSDate+Chats.h"
#import "Utility.h"
#import "AppConstant.h"
#import "LMUserProfileViewController.h"

#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface LMChatViewController ()

@property (strong, readwrite, nonatomic) NSString *firebaseAddress;
@property (strong, readwrite, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSMutableOrderedSet *messages;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *typingLabel;

@property (assign, nonatomic) BOOL isTyping;
@property (assign, nonatomic) NSUInteger numberOfMessagesToShow;

@property (strong, nonatomic) Firebase *messageFirebase;
@property (strong, nonatomic) Firebase *typingFirebase;
@property (strong, nonatomic) Firebase *memberFirebase;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingMessageBubble;
@property (strong, nonatomic) JSQMessagesBubbleImageFactory *bubbleFactory;
@property (strong, nonatomic) JSQMessagesAvatarImage *placeholderAvatar;

@property (strong, nonatomic) NSMutableDictionary *avatarImages;

@end

@implementation LMChatViewController

static NSUInteger sectionMessageCountIncrementor = 10;

-(instancetype) initWithFirebaseAddress:(NSString *)address andGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        _firebaseAddress = address;
        _groupId = groupId;
        _archiveMessages = NO;
    }
    return self;
}

-(instancetype) init
{
    [NSException exceptionWithName: @"Use default initilizer" reason:@"Must use designated intializer (initWithFirebase:andGroupId:)" userInfo:nil];
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!_messages) {
        self.messages = [[NSMutableOrderedSet alloc] init];
    }
    
    (self.archiveMessages) ? [self p_loadArchivedMessages] : [self p_setupFirebase];
    
    self.senderDisplayName = [PFUser currentUser].username;
    self.senderId = [PFUser currentUser].objectId;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingMessageBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingMessageBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    
    self.showLoadEarlierMessagesHeader = YES;
    self.numberOfMessagesToShow = 10;
    
    self.titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont lm_noteWorthySmall]];
    [self.titleLabel setText:self.groupId.uppercaseString];
    
    self.typingLabel = [[UILabel alloc] init];
    [self.typingLabel setFont:[UIFont lm_noteWorthyLightTimeStamp]];
    
    for (UILabel *label in @[self.titleLabel, self.typingLabel]) {
        [self.titleView addSubview:label];
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.navigationItem setTitleView:self.titleView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self.memberFirebase childByAppendingPath:self.senderDisplayName] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputToolbar endEditing:YES];
    [self.memberFirebase updateChildValues:@{self.senderDisplayName : @{}}];
    
    if (self.archiveMessages) [self p_archiveMessages];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CENTER_VIEW_H(_titleView, _titleLabel);
    CENTER_VIEW_H(_titleView, _typingLabel);
    
    ALIGN_VIEW_BOTTOM_CONSTANT(_titleView, _titleLabel, 5);
    ALIGN_VIEW_TOP_CONSTANT(_titleView, _typingLabel, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.messages = nil;
}

-(void)dealloc
{
    [self.messageFirebase removeAllObservers];
}

#pragma mark - Firebase setup

-(void) p_setupFirebase
{
    self.messageFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/messages", _firebaseAddress, _groupId]];
    self.typingFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/typing", _firebaseAddress, _groupId]];
    self.memberFirebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@/members", _firebaseAddress, _groupId]];
    
    __block BOOL initialized = NO;
    
    [self.typingFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self p_updateTypingLabel:snapshot];
    }];
    
    [self.memberFirebase observeEventType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self p_updateTitleLabel:snapshot];
    }];
    
    [self.messageFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self p_addMessage:snapshot.value];
    }];
    
    [self.messageFirebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self finishReceivingMessage];
        [self scrollToBottomAnimated:NO];
        self.automaticallyScrollsToMostRecentMessage = YES;
        initialized = YES;
    }];
}


#pragma mark - JSQMessagesViewController Delegate

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self p_sendMessage:text withMedia:nil];
    [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
    self.isTyping = false;
}

-(void) didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSUInteger difference = self.messages.count - self.numberOfMessagesToShow;
    
    if (difference > sectionMessageCountIncrementor) {
        self.numberOfMessagesToShow += sectionMessageCountIncrementor;
    } else {
        self.numberOfMessagesToShow += difference;
    }
    
    [self.collectionView reloadData];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    LMUserProfileViewController *profileVC = [[LMUserProfileViewController alloc] initWithUserId:senderId];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [self p_sendMessage:nil withMedia:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSQMessagesCollectionView Data Source

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self p_messageAtIndexPath:indexPath];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingMessageBubble;
    }
    
    return self.incomingMessageBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self p_messageAtIndexPath:indexPath];
    NSString *senderId = message.senderId;
    
    if (!_avatarImages) {
        self.avatarImages = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.avatarImages objectForKeyedSubscript:senderId]) return [self.avatarImages objectForKey: senderId];
    
    if (!_placeholderAvatar) {
        self.placeholderAvatar = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"?" backgroundColor:[UIColor lightGrayColor] textColor:[UIColor whiteColor] font:[UIFont fontWithName:@"Noteworthy-Light" size:12] diameter:30.0f ];
    }
    
    PFUser *user = [PFUser objectWithoutDataWithObjectId:senderId];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedUser, NSError *error) {
        PFFile *thumbnailFile = [fetchedUser objectForKey:PF_USER_THUMBNAIL];
        [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:data] diameter:30.0f];
            [self.avatarImages setValue:avatar forKey:senderId];
            [self.collectionView reloadData];
        }];
    }];
    
    return self.placeholderAvatar;
    
}

#pragma mark - UICollectionView Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.messages.count < self.numberOfMessagesToShow) {
        return self.messages.count;
    }
    
    return self.numberOfMessagesToShow;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - TextField Delegate

-(void)textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    if (self.isTyping == false && textView.text.length > 0) {
        [[self.typingFirebase childByAppendingPath:self.senderDisplayName] setValue:@{@"senderDisplayName" : self.senderDisplayName}];
        self.isTyping = true;
    } else if (self.isTyping == true && textView.text.length == 0) {
        [self.typingFirebase updateChildValues:@{self.senderDisplayName : @{}}];
        self.isTyping = false;
    }
}

#pragma mark - NSKeyedArchiver

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}


#pragma mark - Private Methods

-(void) p_addMessage:(NSDictionary *)message
{
    NSUInteger currentMessageCount = self.messages.count;
    
    NSString *type = message[@"type"];
    NSDate *date = [NSDate lm_stringToDate:message[@"date"]];
    NSString *senderId = message[@"senderId"];
    NSString *senderDisplayName = message[@"senderDisplayName"];
    
    JSQMessage *jsqMessage;
    JSQMessage *lastMessage = [self.messages lastObject];
    
    if (date > lastMessage.date || lastMessage == nil) {
        
        if ([type isEqualToString:@"text"]) {
            
            jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:message[@"text"]];
            
        } else {
            
            if ([type isEqualToString:@"picture"]) {
                
                JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
                jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:mediaItem];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message[@"picture"]]];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.responseSerializer = [AFImageResponseSerializer serializer];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    mediaItem.image = (UIImage *)responseObject;
                    [self.collectionView reloadData];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed retreiving message");
                }];
                
                [[NSOperationQueue mainQueue] addOperation:operation];
            }
        }
        
        [self.messages addObject:jsqMessage];
        [self.delegate lastMessage:message forChat:self.groupId];
        
        if ([senderId isEqualToString:self.senderId]) {
            [self finishSendingMessageAnimated:YES];
            
        } else {
            NSUInteger newMessagecount = self.messages.count - currentMessageCount;
            if (newMessagecount) {
                //Can use to archive message and update new message count in UI
            }
            
            if ([jsqMessage isMediaMessage]) {
                JSQMediaItem *mediaItem = (JSQMediaItem *)jsqMessage.media;
                mediaItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            
            [self finishReceivingMessageAnimated:YES];
        }
    }
}

-(void) p_loadArchivedMessages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [self pathForFilename:[NSString stringWithFormat:@"%@", _groupId]];
        NSMutableOrderedSet *archivedMessages = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        if (archivedMessages.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messages = archivedMessages;
                [self finishReceivingMessage];
                [self scrollToBottomAnimated:NO];
                [self p_setupFirebase];
            });
        } else {
            [self p_setupFirebase];
        }
    });
}

-(void) p_archiveMessages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [self pathForFilename:[NSString stringWithFormat:@"%@", _groupId]];
        NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:self.messages];
        
        NSError *dataError;
        BOOL wroteSuccessfully = [messageData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write messages to file: %@", dataError);
        }
    });
}

-(void) p_updateTypingLabel:(FDataSnapshot *)change
{
    NSUInteger childrenCount = change.childrenCount;
    NSMutableArray *children;
    
    if (childrenCount) {
        children = [[NSMutableArray alloc] init];
        for (FDataSnapshot *child in change.children) {
            if (![[child key] isEqualToString:self.senderDisplayName]) {
                [children addObject:[child key]];
            }
        }
    }
    
    if (children.count > 1) {
        [self.typingLabel setText:@"2 or more people are typing..."];
    } else if (children.count == 1){
        [self.typingLabel setText:[NSString stringWithFormat:@"%@ is typing...", children[0]]];
    } else {
        [self.typingLabel setText:@""];
    }
}

-(void) p_updateTitleLabel:(FDataSnapshot *)change
{
    NSUInteger childrenCount = change.childrenCount;
    
    if (childrenCount == 1) {
        [self.titleLabel setText:[NSString stringWithFormat:@"%@ (Just You!)", self.groupId.uppercaseString]];
        return;
    }
    
    [self.titleLabel setText:[NSString stringWithFormat:@"%@ (%lu Members)", self.groupId.uppercaseString, (unsigned long)childrenCount]];
}

-(JSQMessage *) p_messageAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger path = indexPath.item;
    NSUInteger items = self.messages.count;
    
    if (self.numberOfMessagesToShow > self.messages.count)
        return self.messages[path];
    
    return self.messages[(items - self.numberOfMessagesToShow) + path];
}

-(void) p_sendMessage:(NSString *)text withMedia:(id)media
{
    NSString *dateString = [NSString lm_dateToString:[NSDate date]];
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    message[@"senderId"] = self.senderId;
    message[@"senderDisplayName"] = self.senderDisplayName;
    message[@"date"] = dateString;
    
    
    if (text) {
        message[@"type"] = @"text";
        message[@"text"] = text;
        
        [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error != nil) {
                NSLog(@"Error Sending Message - Check network");
            }
        }];
        
    } else if (media) {
        PFFile *file;
        
        if ([media isKindOfClass:[UIImage class]]) {
            file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(media, 0.9)];
            
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error == nil) {
                    message[@"picture"] = file.url;
                    message[@"text"] = @"Picture Message";
                    message[@"type"] = @"picture";
                    
                    [[self.messageFirebase childByAutoId] setValue:message withCompletionBlock:^(NSError *error, Firebase *ref) {
                        if (error != nil) {
                            NSLog(@"Error Sending Message - Check network");
                        }
                    }];
                }
            }];
        }
    }
}

#pragma mark - Setter Methods
-(void) setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
}

#pragma mark - Getter Methods
-(NSOrderedSet *) allMessages
{
    return [self.messages copy];
}

@end