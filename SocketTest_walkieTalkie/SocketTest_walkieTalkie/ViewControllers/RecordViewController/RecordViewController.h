//
//  RecordViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/6/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface RecordViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong , nonatomic) Channel *activeChannelInfo;
@property (nonatomic, strong) AVAudioPlayer *thePlayer;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *audioReceivedButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;

@end
