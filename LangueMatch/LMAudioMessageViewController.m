//
//  LMAudioMessageViewController.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/1/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMAudioMessageViewController.h"
#import "Utility.h"

#import <AVFoundation/AVFoundation.h>

@interface LMAudioMessageViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIImageView *microphoneView;
@property (strong, nonatomic) UIImageView *playButton;

@end

@implementation LMAudioMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelRecording = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelRecording)];
    [self.navigationItem setLeftBarButtonItem:cancelRecording];
    
    UIBarButtonItem *sendRecording = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendRecording)];
    [self.navigationItem setRightBarButtonItem:sendRecording];
    
    UIImage *microphone = [UIImage imageNamed:@"microphone.png"];
    _microphoneView = [[UIImageView alloc] initWithImage:microphone];
    _microphoneView.frame = CGRectMake(0, 0, 100, 100);
    [_microphoneView setUserInteractionEnabled:YES];

    [self.view addSubview:_microphoneView];
    _microphoneView.translatesAutoresizingMaskIntoConstraints = NO;

    
    UIImage *playImage = [UIImage imageNamed:@"play.png"];
    _playButton = [[UIImageView alloc] initWithImage:playImage];
    _playButton.frame = CGRectMake(0, 0, 100, 100);
    [_playButton setUserInteractionEnabled:YES];
    
    [self.view addSubview:_playButton];
    _playButton.translatesAutoresizingMaskIntoConstraints = NO;

    
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
    
    CENTER_VIEW(self.view, _microphoneView);
    CENTER_VIEW_H(self.view, _playButton);
    ALIGN_VIEW_BOTTOM_CONSTANT(self.view, _playButton, -200);
}
                                   
-(void) record
{
    NSLog(@"Record button pressed");
}

-(void) startRecording
{
    NSLog(@"Recording");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view == _microphoneView)
    {
        NSLog(@"Touches Began on record button");
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [recorder record];
        
    }
    else if (touch.view == _playButton)
    {
        if (!recorder.recording) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            [player setDelegate:self];
            [player play];
        }
        
        NSLog(@"Touches Began on play button");
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
        
        NSLog(@"Touches Ended on record button");
    }
    else if (touch.view == _playButton)
    {
        [self.playButton setHighlighted:NO];
        NSLog(@"Touches Ended on play button");
    }
}

-(void) cancelRecording
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) sendRecording
{
    if (recorder.url)
    {
        [self.delegate audioRecordingController:self didFinishRecordingWithContents:recorder.url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
