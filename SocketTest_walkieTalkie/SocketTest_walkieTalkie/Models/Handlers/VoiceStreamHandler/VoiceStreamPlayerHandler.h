//
//  VoiceStreamPlayerHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface VoiceStreamPlayerHandler : NSObject{
    NSString * _receivedStreamFileName, *_SoundfilePath;
    int chunkCounter;
    NSMutableData *audioData;
    NSData *finalAudioData;
}

+(VoiceStreamPlayerHandler*)sharedHandler;

@end
