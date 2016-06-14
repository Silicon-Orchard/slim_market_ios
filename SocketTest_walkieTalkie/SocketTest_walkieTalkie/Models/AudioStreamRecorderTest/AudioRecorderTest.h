//
//  AudioRecorderTest.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/24/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>

#define NUM_BUFFERS 1

typedef struct
{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    AudioFileID                 audioFile;
    SInt64                      currentPacket;
    bool                        recording;
}RecordState;


//typedef struct
//{
//    AudioStreamBasicDescription _playerdataFormat;
//    AudioQueueRef               _playerQueue;
//    AudioQueueBufferRef         _playerBuffers[NUM_BUFFERS];
//    AudioFileID                 _playerAudioFile;
//    SInt64                      _playerCurrentPacket;
//    bool                        isPlaying;
//}PlayState;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs);


@interface AudioRecorderTest : NSObject{
    RecordState recordState;
//    PlayState playState;

}

@property (nonatomic, strong) NSMutableArray *recordedAudioDataArray;

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format;
- (void)startRecording;
- (void)stopRecording;
- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData;
//- (void)startMediaPlayer;
//+(AudioRecorderTest*)sharedHandler;
//- (id)init;


@end
