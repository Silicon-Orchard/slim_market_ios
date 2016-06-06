//
//  VoiceStreamHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/17/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>



@interface VoiceStreamHandler : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    AVAudioRecorder *_recorder;
    NSTimer * _recordTimer;
//    BOOL _isStreaming;
}

@property (assign, nonatomic) BOOL isStreaming;
@property (strong, nonatomic) AVAudioPlayer * thePlayer;

+(VoiceStreamHandler*)sharedHandler;
-(void) initializeRecorder;
-(void)startStreaming;
-(void)stopStreaming;

@end
