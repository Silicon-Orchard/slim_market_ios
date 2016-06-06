//
//  AudioRecorderTest_StreamPlayer.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/30/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioRecorderTest_StreamPlayer : NSObject


typedef struct
{
    AudioStreamBasicDescription _playerdataFormat;
    AudioQueueRef               _playerQueue;
    AudioQueueBufferRef         _playerBuffers[NUM_BUFFERS];
    AudioFileID                 _playerAudioFile;
    SInt64                      _playerCurrentPacket;
    bool                        isPlaying;
}PlayState;

+(AudioRecorderTest_StreamPlayer*)sharedHandler;
- (void)startMediaPlayer;
- (void)stopMediaPlayer;
-(void)enqueueBufferWithAudioData:(NSData *) audioData;
-(BOOL)isPlayerRunning;

@end
