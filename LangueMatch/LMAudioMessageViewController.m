//
//  LMAudioMessageViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/1/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMAudioMessageViewController.h"
#import "Utility.h"
#import "UIFont+ApplicationFonts.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface LMAudioMessageViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIImageView *trashView;
@property (strong, nonatomic) UIImageView *microphoneView;
@property (strong, nonatomic) UIImageView *playButton;
@property (strong, nonatomic) UIImageView *sendButton;

@property (strong, nonatomic) UILabel *recordLabel;
@property (strong, nonatomic) UILabel *sendLabel;

@end

@implementation LMAudioMessageViewController

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super init]) {
        self.view.frame = frame;
        
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _trashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trash"]];
    _microphoneView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ring"]];
    _playButton = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"play"]];
    _sendButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    
    _recordLabel = [[UILabel alloc] init];
    _recordLabel.font = [UIFont lm_noteWorthyLightTimeStamp];
    _recordLabel.text = @"HOLD TO RECORD >";
    [_recordLabel sizeToFit];
    
    _sendLabel = [[UILabel alloc] init];
    _sendLabel.font = [UIFont lm_noteWorthyLightTimeStamp];
    _sendLabel.text = @"SEND";
    [_sendLabel sizeToFit];
    
    for (UIView *view in @[self.trashView, self.microphoneView, self.playButton, self.sendButton, self.recordLabel, self.sendLabel]) {
        [self.view addSubview:view];
        [view setUserInteractionEnabled:YES];
        view.frame = CGRectMake(0, 0, 44, 44);
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }

    
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"MyAudioMemo.m4a", nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSMutableDictionary *recorderSetting = [[NSMutableDictionary alloc] init];
    
    [recorderSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recorderSetting setValue:[NSNumber numberWithInt:44100.0] forKey:AVSampleRateKey];
    [recorderSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recorderSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CENTER_VIEW(self.view, _playButton);
    
    ALIGN_VIEW_LEFT_CONSTANT(self.view, _trashView, 10);
    CENTER_VIEW_V(self.view, _trashView);
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.view, _microphoneView, -10);
    CENTER_VIEW_V(self.view, _microphoneView);
    
    ALIGN_VIEW_RIGHT_CONSTANT(self.view, _recordLabel, -55);
    CENTER_VIEW_V(self.view, _recordLabel);
    
    ALIGN_VIEW_LEFT_CONSTANT(self.view, _sendButton, 65);
    CENTER_VIEW_V(self.view, _sendButton);
    
    ALIGN_VIEW_LEFT_CONSTANT(self.view, _sendLabel, 100);
    CENTER_VIEW_V(self.view, _sendLabel);
}

#pragma mark - Touch Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view == _microphoneView)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        self.recordLabel.text = @"RECORDING";
        [self.view layoutIfNeeded];
        
        AudioServicesPlaySystemSound(1113);
        [recorder record];
    }
    else if (touch.view == _playButton)
    {
        if (!recorder.recording) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            [player setDelegate:self];
            [player play];
        }
    }
    
    else if (touch.view == _trashView)
    {
        [self.delegate cancelAudioRecorder:self];
    }
    
    else if (touch.view == _sendButton)
    {
        [self.delegate audioRecordingController:self didFinishRecordingWithContents:recorder.url];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view == _microphoneView)
    {
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        AudioServicesPlaySystemSound(1114);
        
        self.recordLabel.text = @"HOLD TO RECORD >";
        [self.view layoutIfNeeded];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
