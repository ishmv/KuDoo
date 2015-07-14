//
//  JSQAudioMediaItem.m
//  Pods
//
//  Created by Travis Buttaccio on 5/4/15.
//
//

#import "JSQAudioMediaItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIColor+applicationColors.h"
#import "UIFont+ApplicationFonts.h"

#import "UIImage+JSQMessages.h"

@interface JSQAudioMediaItem ()

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) UIView *cachedVideoImageView;
@property (strong, nonatomic) UIImageView *playIcon;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation JSQAudioMediaItem

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedVideoImageView = nil;
    }
    return self;
}


- (void)dealloc
{
    _fileURL = nil;
    _cachedVideoImageView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVideoImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVideoImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedVideoImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        self.playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play.png"]];
        self.playIcon.frame = CGRectMake(15, 10, 30, 30);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.contentMode = UIViewContentModeLeft;
        [view addSubview:self.playIcon];
        view.backgroundColor = (self.appliesMediaViewMaskAsOutgoing) ? [UIColor lm_beigeColor] : [UIColor lm_wetAsphaltColor];
        
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.fileURL];
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];

        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.playIcon.frame) + 20, 7.5, CGRectGetWidth(view.frame) - CGRectGetWidth(self.playIcon.frame) - 35, 35)];
        [self.slider setUserInteractionEnabled:NO];
        [view addSubview:self.slider];
        
        view.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
        self.cachedVideoImageView = view;
    }
    
    return self.cachedVideoImageView;
}

-(CGSize)mediaViewDisplaySize
{
    return CGSizeMake(200, 50);
}

-(void) play
{
    self.playIcon.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.playIcon.transform = CGAffineTransformIdentity;
        
        if (self.slider.value != 0) {
            self.slider.value = 0;
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        self.slider.maximumValue = 1000 * CMTimeGetSeconds([self.player.currentItem duration]);
        
        [self.player play];
        
    } completion:^(BOOL finished) {
        
    }];

}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQAudioMediaItem *videoItem = (JSQAudioMediaItem *)object;
    
    return [self.fileURL isEqual:videoItem.fileURL]
    && self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQAudioMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL
                                                                   isReadyToPlay:self.isReadyToPlay];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}


#pragma mark - AVAudioPlayer Delegate

-(void) updateSlider
{
    self.slider.value = 1000 * CMTimeGetSeconds([self.player currentTime]);
}


#pragma mark - NSNotification

-(void) playerFinishedPlaying:(NSNotification *)notification
{
    self.slider.value = CMTimeGetSeconds([self.player.currentItem duration]);
    [self.timer invalidate];
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero];
    [self.player pause];
}



@end
