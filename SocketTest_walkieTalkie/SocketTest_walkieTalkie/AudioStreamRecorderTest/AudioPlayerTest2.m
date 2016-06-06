//
//  AudioPlayerTest2.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "AudioPlayerTest2.h"
#include <pthread.h>

@implementation AudioPlayerTest2
//
//// ----------------------------
//// STEP 0. Once create AQs and calculate time to play one audioQueue buffer.
//- (int) open
//{
//    // allocate a struct for storing our state
//    myData = (MyData*)calloc(1, sizeof(MyData));
//    
//    // initialize a mutex and condition so that we can block on buffers in use.
//    pthread_mutex_init(&myData->mutex, NULL);
//    pthread_cond_init(&myData->cond, NULL);
//    pthread_cond_init(&myData->done, NULL);
//    
//    // format description
//    AudioStreamBasicDescription asbd;
//    //UInt32 asbdSize = sizeof(asbd);
////    setupAudioFormat(&asbd);
//    
//    // determine play time for single buffer (just for PCM)
////    bufPlayTime = (kBufferByteSize / 2/* / asbd.mBytesPerPacket*/) * asbd.mFramesPerPacket / asbd.mSampleRate;
//    
//    // create audio queues
//    for(int j = 0; j < 2; j++)
//    {
//        // create the audio queue
//        OSStatus err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, myData, NULL, NULL, 0, &myData->audioQueue[j]);
//        if (err) { PRINTERROR("AudioQueueNewOutput"); myData->failed = true; }
//        
//        // listen for kAudioQueueProperty_IsRunning
//        err = AudioQueueAddPropertyListener(myData->audioQueue[j], kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, myData);
//        if (err) { PRINTERROR("AudioQueueAddPropertyListener"); myData->failed = true; }
//    }
//    
//    // allocate first audio queue buffers
//    for (unsigned int i = 0; i < kNumAQBufs; ++i) {
//        OSStatus err = AudioQueueAllocateBuffer(myData->audioQueue[0], kAQBufSize, &myData->audioQueueBuffer[0][i]);
//        if (err) { PRINTERROR("AudioQueueAllocateBuffer"); myData->failed = true; }
//    }
//}
//
//// STEP 2. Push audio to buffer.
//void HandleOutputBuffer(void *							inClientData,
//                        UInt32							inNumberBytes,
//                        const void *					inInputData)
//{
//    // this is called by audio file stream when it finds packets of audio
//    MyData* myData = (MyData*)inClientData;
//    
//    SInt64 packetSize = inNumberBytes;
//    
//    // if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
//    size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
//    if (bufSpaceRemaining < packetSize) {
//        MyEnqueueBuffer(myData);
//        WaitForFreeBuffer(myData);
//    }
//    
//    // copy data to the audio queue buffer
//    AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->aqIndex][myData->fillBufferIndex];
//    memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)inInputData, packetSize);
//    // keep track of bytes filled and packets filled
//    myData->bytesFilled += packetSize;
//}
//
//void MyAudioQueueIsRunningCallback(void*				inClientData,
//                                   AudioQueueRef		inAQ,
//                                   AudioQueuePropertyID	inID)
//{
//    MyData* myData = (MyData*)inClientData;
//    
//    UInt32 running;
//    UInt32 size;
//    OSStatus err = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size);
//    if (err) { PRINTERROR("get kAudioQueueProperty_IsRunning"); myData->error = ERR_AQ_GET_PROPERTY; return; }
//    if (!running)
//    {
//        // STEP 5. When kAudioQueueProperty_IsRunning changes to "false", free currently stopped AQ buffers.
//        
//        pthread_mutex_lock(&myData->mutex);
//        pthread_cond_signal(&myData->done);
//        pthread_mutex_unlock(&myData->mutex);
//        
//        printf("free buffers\n");
//        unsigned int aqIndex = (inAQ == myData->audioQueue[0]) ? 0 : 1;		// detect index of stopped AudioQueue
//        for(int i = 0; i < kNumAQBufs; i++)
//        {
//            AudioQueueFreeBuffer(inAQ, myData->audioQueueBuffer[aqIndex][i]);
//            if (err) { PRINTERROR("AudioQueueFreeBuffer"); break; }
//        }
//    }
//    else
//    {
//        // STEP 3. When kAudioQueueProperty_IsRunning changes to "true", start AQPlayedBufferTimer.
//        
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];     // init pool
//        [(id)refToSelfP setBufferPlayedDelay];
//        [pool release];                                                 // release pool
//    }
//}
//
//- (void) setBufferPlayedDelay
//{
//    [self performSelector:@selector(bufferPlayed:) withObject:self afterDelay:bufPlayTime];
//}
//
//// STEP 4. When AQPlayedBufferTimer calls callback, check count of enqueued buffers not played. Etc.
//- (void) bufferPlayed: (AudioPlayback *) ap
//{
//    enqueredBufCount--;
//    if (!myData->started) return;
//    
//    if (enqueredBufCount > 0)
//    {
//        // still can use this AQ
//        [self performSelector:@selector(bufferPlayed:) withObject:self afterDelay:bufPlayTime];
//    }
//    else
//    {
//        printf("     all buffers played. Stopping...\n");
//        
//        // index of current audioQueue
//        unsigned int curIndex = myData->aqIndex;
//        
//        // index of next audioQueue
//        unsigned int aqIndex = myData->aqIndex + 1;
//        if (aqIndex > 1) aqIndex = 0;
//        
//        // allocate buffers of next audioQueue
//        for (unsigned int i = 0; i < kNumAQBufs; ++i) {
//            OSStatus err = AudioQueueAllocateBuffer(myData->audioQueue[aqIndex], kAQBufSize, &myData->audioQueueBuffer[aqIndex][i]);
//            if (err) { PRINTERROR("AudioQueueAllocateBuffer"); myData->failed = true; break; }
//        }
//        
//        // copy unused audio buffer bytes (if exist)
//        //if (myData->bytesFilled > 0) {
//        //    // copy data from current audio queue buffer to next
//        //    AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[curIndex][myData->fillBufferIndex];
//        //    AudioQueueBufferRef fillBufNext = myData->audioQueueBuffer[aqIndex][myData->fillBufferIndex];
//        //    memcpy((char*)fillBufNext->mAudioData, (char*)fillBuf->mAudioData, myData->bytesFilled);
//        //}
//        
//        // enqueue last buffer if exist (use ONLY if need to play REST data!). Use BEFORE switching audioQueue!!!
//        BOOL playRest = NO;
//        if (myData->bytesFilled > 0) {
//            // first enqueue rest audio
//            MyEnqueueBuffer(myData);
//            //WaitForFreeBuffer(myData);
//            myData->bytesFilled = 0;		// reset bytes filled
//            myData->packetsFilled = 0;		// reset packets filled
//            // -1 for just enquered audio
//            filledBufCount--;
//            enqueredBufCount--;
//            
//            playRest = YES;
//        }
//        
//        // switch audioQueue
//        myData->aqIndex = aqIndex;
//        
//        // play rest audio buffer bytes (if exist) and stop after that
//        if (playRest) {
//            if ( [self playNstopAudioQueue:curIndex] )
//                NSLog(@"Error to play rest AQ");
//        }
//        // if not exist, just stop audioQueue
//        else
//        {
//            if ( [self stopAudioQueue:curIndex] )
//                NSLog(@"Error to stop AQ");
//        }
//    }
//}
//
//- (int) playNstopAudioQueue: (unsigned int) aqIndex
//{
//    if (!myData->started) return 0;
//    myData->started = false;            // set this flag BEFORE call AudioQueueStop
//    
//    printf("flushing\n");
//    OSStatus err = AudioQueueFlush(myData->audioQueue[aqIndex]);
//    if (err) { PRINTERROR("AudioQueueFlush"); myData->error = ERR_AQ_FLUSH; return 1; }
//    
//    printf("stopping\n");
//    err = AudioQueueStop(myData->audioQueue[aqIndex], false);
//    if (err) { PRINTERROR("AudioQueueStop"); return 1; }
//    
//    printf("done\n");
//    return 0;
//}
//
//- (int) stopAudioQueue: (unsigned int) aqIndex
//{
//    if (!myData->started) return 0;
//    myData->started = false;            // set this flag BEFORE call AudioQueueStop
//    
//    printf("stopping\n");
//    OSStatus err = AudioQueueStop(myData->audioQueue[aqIndex], true);
//    if (err) { PRINTERROR("AudioQueueStop"); return 1; }
//    
//    printf("done\n");
//    return 0;
//}

@end
