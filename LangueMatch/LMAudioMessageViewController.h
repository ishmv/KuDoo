//
//  LMAudioMessageViewController.h
//  LangueMatch
//
//  Created by Travis Buttaccio on 5/1/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMAudioMessageViewController;

@protocol LMAudioMessageViewControllerDelegate <NSObject>

-(void) audioRecordingController:(LMAudioMessageViewController *)controller didFinishRecordingWithContents:(NSURL *)url;
-(void) cancelAudioRecorder:(LMAudioMessageViewController *)controller;

@end

@interface LMAudioMessageViewController : UIViewController

-(instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, weak) id <LMAudioMessageViewControllerDelegate> delegate;

@end
