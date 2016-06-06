//
//  AudioRecorderTest_StreamPlayer.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/30/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "AudioRecorderTest_StreamPlayer.h"

@implementation AudioRecorderTest_StreamPlayer{
        PlayState playState;

}

+(AudioRecorderTest_StreamPlayer*)sharedHandler{
    static AudioRecorderTest_StreamPlayer *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[AudioRecorderTest_StreamPlayer alloc] init];
        
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format {
 

    format->mSampleRate = 16000.0;
    
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
    format->mFramesPerPacket  = 1;
    format->mChannelsPerFrame = 1;
    format->mBytesPerFrame    = sizeof(Float32);
    format->mBytesPerPacket   = sizeof(Float32);
    format->mBitsPerChannel   = sizeof(Float32) * 8;
    format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian     |
    kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
    
 
//    format->mFormatID = kAudioFormatLinearPCM;
//    format->mSampleRate =  12000.0;
//    format->mChannelsPerFrame = 2;
//    format->mBytesPerFrame = 4;
//    format->mFramesPerPacket = 1;
//    format->mBytesPerPacket = 4;
//    format->mBitsPerChannel = 16;
//    format->mReserved = 0;
//    format->mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}



// PlayBackReceiveBytes

void OutputBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    //Cast userData to MediaPlayer Objective-C class instance
    AudioRecorderTest_StreamPlayer *mediaPlayer = (__bridge AudioRecorderTest_StreamPlayer *) inUserData;
    // Fill buffer.

//    [mediaPlayer fillAudioBuffer:inBuffer  withAudioData:mediaPlayer.recordedAudioDataArray[0]];
    // Re-enqueue buffer.
//    OSStatus err = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//    if (err != noErr)
//        NSLog(@"AudioQueueEnqueueBuffer() error %d", (int) err);
}

- (void)fillAudioBuffer:(AudioQueueBufferRef)inBuffer withAudioData:(NSData *)audioData{
    UInt32 bytesToRead = inBuffer->mAudioDataBytesCapacity;

    while (bytesToRead > 0) {
        memcpy(inBuffer->mAudioData, audioData.bytes, audioData.length);

    }
    inBuffer->mAudioDataByteSize = kBufferByteSize;
}

- (void)startMediaPlayer {
    AudioStreamBasicDescription streamFormat;
//    streamFormat.mFormatID = kAudioFormatLinearPCM;
//    streamFormat.mSampleRate = 16000.0;
//    streamFormat.mChannelsPerFrame = 1;
//    streamFormat.mBytesPerFrame = sizeof(Float32);
//    streamFormat.mFramesPerPacket = 1;
//    streamFormat.mBytesPerPacket = sizeof(Float32);
//    streamFormat.mBitsPerChannel = sizeof(Float32) * 8;
//    streamFormat.mFormatFlags =kAudioFormatFlagsNativeFloatPacked;

    [self setupAudioFormat:&streamFormat];
    // New input queue
    OSStatus err = AudioQueueNewOutput(&streamFormat, OutputBufferCallback, (__bridge void *) self, nil, nil, 0, &playState._playerQueue);
    if (err != noErr) {
        NSLog(@"AudioQueueNewOutput() error: %d", (int) err);
    }

    int i;
    // Enqueue buffers
    AudioQueueBufferRef buffer;
    for (i = 0; i < NUM_BUFFERS; i++) {
        err = AudioQueueAllocateBuffer(playState._playerQueue, kBufferByteSize, &buffer);
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:err
                                         userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        memset(buffer->mAudioData, 0, kBufferByteSize);
        buffer->mAudioDataByteSize = kBufferByteSize;
        if (err == noErr) {
            err = AudioQueueEnqueueBuffer(playState._playerQueue, buffer, 0, nil);
            if (err != noErr) NSLog(@"AudioQueueEnqueueBuffer() error: %d", (int) err);
        } else {
            NSLog(@"AudioQueueAllocateBuffer() error: %d", (int) err);
            return;
        }
    }

    // Start queue
    err = AudioQueueStart(playState._playerQueue, nil);
    if (err != noErr) NSLog(@"AudioQueueStart() error: %d", (int) err);
    playState.isPlaying = true;

}

-(BOOL)isPlayerRunning{
    return playState.isPlaying;
}

-(void)enqueueBufferWithAudioData:(NSData *) audioData{
    OSStatus err;
    int i;
    // Enqueue buffers
    AudioQueueBufferRef buffer;

    for (i = 0; i < 1; i++) {
        err = AudioQueueAllocateBuffer(playState._playerQueue, kBufferByteSize, &buffer);
//        memset(buffer->mAudioData, 0, kBufferByteSize);
        buffer->mAudioDataByteSize = kBufferByteSize;
        memcpy(buffer->mAudioData, audioData.bytes, audioData.length);

        if (err == noErr) {
            err = AudioQueueEnqueueBuffer(playState._playerQueue, buffer, 0, nil);
            if (err != noErr) NSLog(@"AudioQueueEnqueueBuffer() error: %d", (int) err);
        } else {
            NSLog(@"AudioQueueAllocateBuffer() error: %d", (int) err);
            return;
        }
    }


}

- (void)stopMediaPlayer {
    playState.isPlaying = false;

    AudioQueueStop(playState._playerQueue, true);

    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(playState._playerQueue, playState._playerBuffers[i]);
    }

    AudioQueueDispose(playState._playerQueue, true);
    AudioFileClose(playState._playerAudioFile);
}

@end
