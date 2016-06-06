//
//  VoiceStreamHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/17/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "VoiceStreamHandler.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>


@implementation VoiceStreamHandler{
    NSString * _receivedStreamFileName, *_SoundfilePath;
    int chunkCounter;
    NSMutableData *audioData;
    NSData *finalAudioData;
    NSMutableArray *recordedDataContainerArray;
}


+(VoiceStreamHandler*)sharedHandler{
    static VoiceStreamHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[VoiceStreamHandler alloc] init];

        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}





-(void) initializeRecorder{
    recordedDataContainerArray = [[NSMutableArray alloc] init];
    _receivedStreamFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"stream.caf",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:12000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:4025.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    //[NSNumber numberWithInt:AVAudioQualityMin],
    //AVEncoderAudioQualityKey

    
    // Initiate and prepare the recorder
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings error:&error];
    if (error) {
        NSLog(@"Record Couldn't Start . Error %@", [error localizedDescription]);
    }
    else{
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
}

-(void)startStreaming{
    _isStreaming = YES;
    [self startRecording];
    
    
}

-(void)stopStreaming{
    _isStreaming = NO;
}



-(void)startRecording{
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(stopRecording:) userInfo:nil repeats:NO];
    [_recorder record];
}


-(void)stopRecording:(NSTimer *)timer {
    [timer invalidate];
    _recordTimer = nil;
    [_recorder stop];
    
}

-(void)sendData{
    
    
   
    NSData *zipFileData = [recordedDataContainerArray objectAtIndex:0];
    NSError *error = nil;
//    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
//    
//    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//    long long fileSize = [fileSizeNumber longLongValue];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    self.thePlayer = [[AVAudioPlayer alloc] initWithData:zipFileData error:&error];
    if (error) {
        NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
    }
    else {
        [ self.thePlayer setDelegate:self];
        [ self.thePlayer setNumberOfLoops:0];
        [ self.thePlayer prepareToPlay];
        [ self.thePlayer play];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        for (int i= 0; i<[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs.count; i++) {
            if (![[[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                //            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
                
                    [[asyncUDPConnectionHandler sharedHandler]sendVoiceStreamData:zipFileData  toIPAddress:[[ChannelHandler sharedHandler].currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
                
            }
            
        }
        [recordedDataContainerArray removeObjectAtIndex:0];
        
        
    });
//    if (recordedDataContainerArray.count != 0) {
//        [self sendData];
//    }

    
}


#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"stream.caf"];
    NSData *zipFileData = [[NSData alloc] initWithData: [NSData dataWithContentsOfFile:filePath]];
    [recordedDataContainerArray addObject:zipFileData];
    if (_isStreaming) {
        [self startRecording];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        [self sendData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
        });
    });
    
    //    NSData *recordedAudioFileData = [[AudioFileHandler sharedHandler] dataFromAudioFile:_receivedStreamFileName];
    //    NSString *savedFilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:recordedAudioFileData saveDataAsFileName:@"NewRecord"];
    //
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
    //                                                    message: @"Finish playing the recording!"
    //                                                   delegate: nil
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //    [alert show];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog( @"decode Error !");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Decode Error!"
                                                    message: @"Audio Did Not Arrive Properly!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


//void AudioInputCallback(void * inUserData,
//                        AudioQueueRef inAQ,
//                        AudioQueueBufferRef inBuffer,
//                        const AudioTimeStamp * inStartTime,
//                        UInt32 inNumberPacketDescriptions,
//                        const AudioStreamPacketDescription * inPacketDescs)
//{
////    RecordState * recordState = (RecordState*)inUserData;
////    if (!recordState->recording)
////    {
////        printf("Not recording, returning\n");
////    }
//    
//    // if (inNumberPacketDescriptions == 0 && recordState->dataFormat.mBytesPerPacket != 0)
//    // {
//    //     inNumberPacketDescriptions = inBuffer->mAudioDataByteSize / recordState->dataFormat.mBytesPerPacket;
//    // }
//    
////    printf("Writing buffer %lld\n", recordState->currentPacket);
//    
//    OSStatus status = AudioFileWritePackets(recordState->audioFile,
//                                            false,
//                                            inBuffer->mAudioDataByteSize,
//                                            inPacketDescs,
//                                            recordState->currentPacket,
//                                            &inNumberPacketDescriptions,
//                                            inBuffer->mAudioData);
//    NSLog(@"DATA = %@",[NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize]);
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"Recording" object:[NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize]];
//    
//    if (status == 0)
//    {
//        recordState->currentPacket += inNumberPacketDescriptions;
//    }
//    
//    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
//}
//


#pragma mark Audio unit remote I/O

//AudioUnit *audioUnit = NULL;
//float *convertedSampleBuffer = NULL;
//
//int initAudioSession() {
//    audioUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
//    
//    if(AudioSessionInitialize(NULL, NULL, NULL, NULL) != noErr) {
//        return 1;
//    }
//    
//    if(AudioSessionSetActive(true) != noErr) {
//        return 1;
//    }
//    
//    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
//    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//                               sizeof(UInt32), &sessionCategory) != noErr) {
//        return 1;
//    }
//    
//    Float32 bufferSizeInSec = 0.02f;
//    if(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
//                               sizeof(Float32), &bufferSizeInSec) != noErr) {
//        return 1;
//    }
//    
//    UInt32 overrideCategory = 1;
//    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//                               sizeof(UInt32), &overrideCategory) != noErr) {
//        return 1;
//    }
//    
//    UInt32 overrideCategoryBlueTooth = 1;
//    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
//                               sizeof(UInt32), &overrideCategoryBlueTooth) != noErr) {
//        return 1;
//    }
//    
//    // There are many properties you might want to provide callback functions for:
//    // kAudioSessionProperty_AudioRouteChange
//    // kAudioSessionProperty_OverrideCategoryEnableBluetoothInput
//    // etc.
//    
//    return 0;
//}
//
//#define kOutputBus 0
//#define kInputBus 1
//
//int initAudioStreams(AudioUnit *audioUnit) {
//    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
//    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//                               sizeof(UInt32), &audioCategory) != noErr) {
//        return 1;
//    }
//    
//    UInt32 overrideCategory = 1;
//    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//                               sizeof(UInt32), &overrideCategory) != noErr) {
//        // Less serious error, but you may want to handle it and bail here
//    }
//    
//    AudioComponentDescription componentDescription;
//    componentDescription.componentType = kAudioUnitType_Output;
//    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
//    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
//    componentDescription.componentFlags = 0;
//    componentDescription.componentFlagsMask = 0;
//    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
//    if(AudioComponentInstanceNew(component, audioUnit) != noErr) {
//        return 1;
//    }
//    
//    UInt32 enable = 1;
//    if(AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
//                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
//        return 1;
//    }
//    
//    AURenderCallbackStruct callbackStruct;
//    callbackStruct.inputProc = renderCallback; // Render function
//    callbackStruct.inputProcRefCon = NULL;
//    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback,
//                            kAudioUnitScope_Input, 0, &callbackStruct,
//                            sizeof(AURenderCallbackStruct)) != noErr) {
//        return 1;
//    }
//    
//    callbackStruct.inputProc = playbackCallback;
//    callbackStruct.inputProcRefCon = NULL;
//    AudioUnitSetProperty(*audioUnit,
//                                  kAudioUnitProperty_SetRenderCallback,
//                                  kAudioUnitScope_Output,
//                                  kOutputBus,
//                                  &callbackStruct,
//                                  sizeof(callbackStruct));
//    
//    AudioStreamBasicDescription streamDescription;
//    // You might want to replace this with a different value, but keep in mind that the
//    // iPhone does not support all sample rates. 8kHz, 22kHz, and 44.1kHz should all work.
//    streamDescription.mSampleRate = 44100;
//    // Yes, I know you probably want floating point samples, but the iPhone isn't going
//    // to give you floating point data. You'll need to make the conversion by hand from
//    // linear PCM <-> float.
//    streamDescription.mFormatID = kAudioFormatLinearPCM;
//    // This part is important!
//    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger |
//    kAudioFormatFlagsNativeEndian |
//    kAudioFormatFlagIsPacked;
//    // Not sure if the iPhone supports recording >16-bit audio, but I doubt it.
//    streamDescription.mBitsPerChannel = 16;
//    // 1 sample per frame, will always be 2 as long as 16-bit samples are being used
//    streamDescription.mBytesPerFrame = 2;
//    // Record in mono. Use 2 for stereo, though I don't think the iPhone does true stereo recording
//    streamDescription.mChannelsPerFrame = 1;
//    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame *
//    streamDescription.mChannelsPerFrame;
//    // Always should be set to 1
//    streamDescription.mFramesPerPacket = 1;
//    // Always set to 0, just to be sure
//    streamDescription.mReserved = 0;
//    
//    // Set up input stream with above properties
//    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
//                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
//        return 1;
//    }
//    
//    // Ditto for the output stream, which we will be sending the processed audio to
//    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
//                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
//        return 1;
//    }
//    
//    return 0;
//}
//
//
//
//int startAudioUnit(AudioUnit *audioUnit) {
//    if(AudioUnitInitialize(*audioUnit) != noErr) {
//        return 1;
//    }
//    
//    if(AudioOutputUnitStart(*audioUnit) != noErr) {
//        return 1;
//    }
//    
//    return 0;
//}
//
//OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
//                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
//                        UInt32 numFrames, AudioBufferList *buffers) {
//    OSStatus status = AudioUnitRender(*audioUnit, actionFlags, audioTimeStamp,
//                                      1, numFrames, buffers);
//    if(status != noErr) {
//        return status;
//    }
//    
//    if(convertedSampleBuffer == NULL) {
//        // Lazy initialization of this buffer is necessary because we don't
//        // know the frame count until the first callback
//        convertedSampleBuffer = (float*)malloc(sizeof(float) * numFrames);
//    }
//    
//    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
//    NSLog(@"DATA = %@",[NSData dataWithBytes:buffers->mBuffers->mData length:buffers->mBuffers->mDataByteSize]);
//    
//    // If your DSP code can use integers, then don't bother converting to
//    // floats here, as it just wastes CPU. However, most DSP algorithms rely
//    // on floating point, and this is especially true if you are porting a
//    // VST/AU to iOS.
//    for(int i = 0; i < numFrames; i++) {
//        convertedSampleBuffer[i] = (float)inputFrames[i] / 32768.0f;
//    }
//    
//    // Now we have floating point sample data from the render callback! We
//    // can send it along for further processing, for example:
//    // plugin->processReplacing(convertedSampleBuffer, NULL, sampleFrames);
//    
//    // Assuming that you have processed in place, we can now write the
//    // floating point data back to the input buffer.
//    for(int i = 0; i < numFrames; i++) {
//        // Note that we multiply by 32767 here, NOT 32768. This is to avoid
//        // overflow errors (and thus clipping).
//        inputFrames[i] = (SInt16)(convertedSampleBuffer[i] * 32767.0f);
//    }
//    
//    return noErr;
//}
//
//static OSStatus playbackCallback(void *inRefCon,
//                                 AudioUnitRenderActionFlags *ioActionFlags,
//                                 const AudioTimeStamp *inTimeStamp,
//                                 UInt32 inBusNumber,
//                                 UInt32 inNumberFrames,
//                                 AudioBufferList *ioData) {
//    // Notes: ioData contains buffers (may be more than one!)
//    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
//    // much data is in the buffer.
//    for (int i=0; i < ioData->mNumberBuffers; i++)
//    {
////        AudioBuffer buffer = ioData->mBuffers[i];
////        // copy from your whatever buffer data to output buffer
////        UInt32 size = min(buffer.mDataByteSize, your buffer.size);
////        memcpy(buffer.mData, your buffer, size);
////        buffer.mDataByteSize = size; // indicate how much data we wrote in the buffer
////        
//        // To test if your Audio Unit setup is working - comment out the three
//        // lines above and uncomment the for loop below to hear random noise
//        /*
//         UInt16 *frameBuffer = buffer.mData;
//         for (int j = 0; j < inNumberFrames; j++) {
//         frameBuffer[j] = rand();
//         }
//         */
//    }
//    return noErr;
//}
//
//-(void)startStreamRecording{
//   
//    initAudioSession();
//    initAudioStreams(audioUnit);
//    startAudioUnit(audioUnit);
//   
//}
//
//int stopProcessingAudio(AudioUnit *audioUnit) {
//    if(AudioOutputUnitStop(*audioUnit) != noErr) {
//        return 1;
//    }
//    
//    if(AudioUnitUninitialize(*audioUnit) != noErr) {
//        return 1;
//    }
//    
//    *audioUnit = NULL;
//    return 0;
//}




@end
