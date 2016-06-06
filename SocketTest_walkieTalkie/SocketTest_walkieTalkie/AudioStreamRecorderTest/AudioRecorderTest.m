//
//  AudioRecorderTest.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/24/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//
#import <MacTypes.h>
#import "AudioRecorderTest.h"

#define AUDIO_DATA_TYPE_FORMAT float

@implementation AudioRecorderTest{
    
    NSData *recordedData;
    }


//+(AudioRecorderTest*)sharedHandler{
//    static AudioRecorderTest *mySharedHandler = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        mySharedHandler = [[AudioRecorderTest alloc] init];
//        
//        // Do any other initialisation stuff here
//    });
//    
//    return mySharedHandler;
//}

void *refToSelf;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs) {
    
    RecordState * recordState = (RecordState*)inUserData;
    
    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
    
    AudioRecorderTest *rec = (__bridge AudioRecorderTest *) refToSelf;
    
    NSLog(@"");
    NSData *dataToSend = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
    NSDictionary* userInfo = @{@"dataToSend": dataToSend};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bufferRecorded" object:nil userInfo:userInfo];
    
    
    
    [rec feedSamplesToEngine:inBuffer->mAudioDataBytesCapacity audioData:inBuffer->mAudioData];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.recordedAudioDataArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recorded:) name:@"bufferRecorded" object:nil ];
//        en = new ASREngine();
//        en->engineInit("1293.lm", "1293.dic");
//        refToSelf = self;
    }
    return self;
}

-(void) recorded:(NSNotification*)notification{
    NSDictionary * userInfo = notification.userInfo;
    NSData *dataToSend = [userInfo objectForKey:@"dataToSend"];
    recordedData = dataToSend;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        for (int i= 0; i<[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs.count; i++) {
            if (![[[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                //            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
                
                [[asyncUDPConnectionHandler sharedHandler]sendVoiceStreamData:dataToSend  toIPAddress:[[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
                
            }
            
        }
        
        
    });
//    [self.recordedAudioDataArray addObject:dataToSend];
//    if (self.recordedAudioDataArray.count > 10) {
//        [self.recordedAudioDataArray removeObjectAtIndex:0];
//    }
//    [[AudioRecorderTest_StreamPlayer sharedHandler] enqueueBufferWithAudioData:dataToSend];
    
//    [self startMediaPlayer];
    
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format {
//    format->mSampleRate = 16000.0;
//    
//    format->mFormatID = kAudioFormatLinearPCM;
//    format->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
//    format->mFramesPerPacket  = 1;
//    format->mChannelsPerFrame = 1;
//    format->mBytesPerFrame    = sizeof(Float32);
//    format->mBytesPerPacket   = sizeof(Float32);
//    format->mBitsPerChannel   = sizeof(Float32) * 8;
    

    format->mSampleRate = 16000.0;
    
    format->mFormatID = kAudioFormatLinearPCM;
//        format->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
    format->mFramesPerPacket  = 1;
    format->mChannelsPerFrame = 1;
    format->mBytesPerFrame    = sizeof(Float32);
    format->mBytesPerPacket   = sizeof(Float32);
    format->mBitsPerChannel   = sizeof(Float32) * 8;
    format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian     |
    kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
 
    
//    format->mFormatID = kAudioFormatLinearPCM;
//    format->mSampleRate = 12000.0;
//   format->mChannelsPerFrame = 2;
//    format->mBytesPerFrame = 4;
//    format->mFramesPerPacket = 1;
//    format->mBytesPerPacket = 4;
//    format->mBitsPerChannel = 16;
//    format->mReserved = 0;
//    format->mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;

    
    

}

- (void)startRecording {
    [self setupAudioFormat:&recordState.dataFormat];
    
    recordState.currentPacket = 0;
    
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    if (status == 0) {
        
        for (int i = 0; i < NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(recordState.queue, kBufferByteSize, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, nil);
        }
        
        recordState.recording = true;
        
        status = AudioQueueStart(recordState.queue, NULL);
    }
}

- (void)stopRecording {
    recordState.recording = false;
    
    AudioQueueStop(recordState.queue, true);
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    
    AudioQueueDispose(recordState.queue, true);
    AudioFileClose(recordState.audioFile);
    
//    [self stopMediaPlayer];
}

- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData {
    int sampleCount = audioDataBytesCapacity / sizeof(AUDIO_DATA_TYPE_FORMAT);
//    AUDIO_DATA_TYPE_FORMAT *samples = (AUDIO_DATA_TYPE_FORMAT*)audioData;
//    
//    //Do something with the samples
//    for ( int i = 0; i < sampleCount; i++) {
//        //Do something with samples[i]
//    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//
////
////// PlayBackReceiveBytes
////
//void OutputBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
//    //Cast userData to MediaPlayer Objective-C class instance
//    AudioRecorderTest *mediaPlayer = (__bridge AudioRecorderTest *) inUserData;
//    // Fill buffer.
//    
//    [mediaPlayer fillAudioBuffer:inBuffer  withAudioData:mediaPlayer.recordedAudioDataArray[0]];
//    // Re-enqueue buffer.
//    OSStatus err = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//    if (err != noErr)
//        NSLog(@"AudioQueueEnqueueBuffer() error %d", (int) err);
//}
//
//- (void)fillAudioBuffer:(AudioQueueBufferRef)inBuffer withAudioData:(NSData *)audioData{
////    if (self.currentAudioPiece == nil || self.currentAudioPiece.duration >= self.currentAudioPieceIndex) {
////        //grab latest sample from sample queue
////        self.currentAudioPiece = sampleQueue.dequeue;
////        self.currentAudioPieceIndex = 0;
////    }
////    
////    //Check for empty sample queue
////    if (self.currentAudioPiece == nil) {
////        NSLog(@"Empty sample queue");
////        memset(inBuffer->mAudioData, 0, kBufferByteSize);
////        return;
////    }
//    
//    UInt32 bytesToRead = inBuffer->mAudioDataBytesCapacity;
//    
//    while (bytesToRead > 0) {
////        UInt32 maxBytesFromCurrentPiece = self.currentAudioPiece.audioData.length - self.currentAudioPieceIndex;
////        //Take the min of what the current piece can provide OR what is needed to be read
////        UInt32 bytesToReadNow = MIN(maxBytesFromCurrentPiece, bytesToRead);
//        
////        NSData *subRange = [self.currentAudioPiece.audioData subdataWithRange:NSMakeRange(self.currentAudioPieceIndex, bytesToReadNow)];
//        //Copy what you can before continuing loop
////        memcpy(inBuffer->mAudioData, subRange.bytes, subRange.length);
//        memcpy(inBuffer->mAudioData, audioData.bytes, audioData.length);
//
////        bytesToRead -= bytesToReadNow;
//        
////        if (bytesToReadNow == maxBytesFromCurrentPiece) {
////            @synchronized (sampleQueue) {
////                self.currentAudioPiece = self.sampleQueue.dequeue;
////                self.currentAudioPieceIndex = 0;
////            }
////        } else {
////            self.currentAudioPieceIndex += bytesToReadNow;
////        }
//    }
//    inBuffer->mAudioDataByteSize = kBufferByteSize;
//    [self.recordedAudioDataArray removeObjectAtIndex:0];
//}
//
//- (void)startMediaPlayer {
////    format->mSampleRate = 16000.0;
////    
////    format->mFormatID = kAudioFormatLinearPCM;
////    format->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
////    format->mFramesPerPacket  = 1;
////    format->mChannelsPerFrame = 1;
////    format->mBytesPerFrame    = sizeof(Float32);
////    format->mBytesPerPacket   = sizeof(Float32);
////    format->mBitsPerChannel   = sizeof(Float32) * 8;
//    AudioStreamBasicDescription streamFormat;
//    streamFormat.mFormatID = kAudioFormatLinearPCM;
//    streamFormat.mSampleRate = 16000.0;
//    streamFormat.mChannelsPerFrame = 1;
//    streamFormat.mBytesPerFrame = sizeof(Float32);
//    streamFormat.mFramesPerPacket = 1;
//    streamFormat.mBytesPerPacket = sizeof(Float32);
//    streamFormat.mBitsPerChannel = sizeof(Float32) * 8;
//    streamFormat.mFormatFlags =kAudioFormatFlagsNativeFloatPacked;
//    
//    [self setupAudioFormat:&streamFormat];
//
////    streamFormat.mFormatID = kAudioFormatLinearPCM;
////    streamFormat.mSampleRate = 44100.0;
////    streamFormat.mChannelsPerFrame = 2;
////    streamFormat.mBytesPerFrame = 4;
////    streamFormat.mFramesPerPacket = 1;
////    streamFormat.mBytesPerPacket = 4;
////    streamFormat.mBitsPerChannel = 16;
////    streamFormat.mReserved = 0;
////    streamFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
//    
//    // New input queue
//    OSStatus err = AudioQueueNewOutput(&streamFormat, OutputBufferCallback, (__bridge void *) self, nil, nil, 0, &playState._playerQueue);
//    if (err != noErr) {
//        NSLog(@"AudioQueueNewOutput() error: %d", (int) err);
//    }
//    
//    int i;
//    // Enqueue buffers
//    AudioQueueBufferRef buffer;
//    for (i = 0; i < 1; i++) {
//        err = AudioQueueAllocateBuffer(playState._playerQueue, kBufferByteSize, &buffer);
//        memset(buffer->mAudioData, 0, kBufferByteSize);
//        buffer->mAudioDataByteSize = kBufferByteSize;
//        if (err == noErr) {
//            err = AudioQueueEnqueueBuffer(playState._playerQueue, buffer, 0, nil);
//            if (err != noErr) NSLog(@"AudioQueueEnqueueBuffer() error: %d", (int) err);
//        } else {
//            NSLog(@"AudioQueueAllocateBuffer() error: %d", (int) err);
//            return;
//        }
//    }
//    
//    // Start queue
//    err = AudioQueueStart(playState._playerQueue, nil);
//    if (err != noErr) NSLog(@"AudioQueueStart() error: %d", (int) err);
//}
//
//- (void)stopMediaPlayer {
//    playState.isPlaying = false;
//    
//    AudioQueueStop(playState._playerQueue, true);
//    
//    for (int i = 0; i < NUM_BUFFERS; i++) {
//        AudioQueueFreeBuffer(playState._playerQueue, playState._playerBuffers[i]);
//    }
//    
//    AudioQueueDispose(playState._playerQueue, true);
//    AudioFileClose(playState._playerAudioFile);
//    self.recordedAudioDataArray = nil;
//}


@end
