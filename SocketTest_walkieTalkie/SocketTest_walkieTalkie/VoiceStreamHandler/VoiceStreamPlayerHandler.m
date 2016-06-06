//
//  VoiceStreamPlayerHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "VoiceStreamPlayerHandler.h"

@implementation VoiceStreamPlayerHandler

+(VoiceStreamPlayerHandler*)sharedHandler{
    static VoiceStreamPlayerHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[VoiceStreamPlayerHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

-(void)initializeStreamReceiver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceStreamArrived:) name:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil];
}

-(void) voiceStreamArrived:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    //    NSLog (@"Successfully received Voice Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE];
    NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];
    NSLog(@"Received Data: voiceMessage\npacket count %d\ntotalPacket %d", [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue], [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]);
    
    if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == 1) {
        
        chunkCounter = 1;
        audioData = [[NSMutableData alloc] initWithData:audioDataFromBase64String];
        _receivedStreamFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
        
        
        
    }
    else{
        chunkCounter ++;
        [audioData appendData:audioDataFromBase64String];
        //        SoundfilePath = [[AudioFileHandler sharedHandler] returnFilePathAfterAppendingData:audioDataFromBase64String toFileName:receivedFileName];
        
        if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]) {
            if (chunkCounter == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]) {
                
                finalAudioData = [[NSData alloc] initWithData:audioData];
                _SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:finalAudioData saveDataAsFileName:_receivedStreamFileName];
//                NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
                chunkCounter = 0;
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setActive:YES error:nil];
                NSError *error = nil;
                AVAudioPlayer * thePlayer = [[AVAudioPlayer alloc] initWithData:finalAudioData error:&error];
                if (error) {
                    NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
                }
                else {
                    [thePlayer setDelegate:self];
                    [thePlayer setNumberOfLoops:0];
                    [thePlayer prepareToPlay];
                    [thePlayer play];
                }
                
            }
           
        }
        
        
    }
}

@end
