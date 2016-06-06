//
//  AudioRecorderViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/5/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioRecorderViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong , nonatomic) Channel *activeChannelInfo;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;

@end
