//
//  AudioRecorderViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/5/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "AudioRecorderViewController.h"
#include <stdlib.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AudioRecorderViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *recordedAudioFileName;
    NSString *recordedAudioSaveFileNameInDocDir;
    NSURL *receivedSoundURL;

}

@end

@implementation AudioRecorderViewController
@synthesize stopButton, playButton, recordPauseButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    recordedAudioFileName = @"MyAudioMemo.m4a";
    // Disable Stop/Play button when application launches
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceived:) name:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];

    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               recordedAudioFileName,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
// Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) channelUpdated:(NSNotification*)notification{
    Channel *newChannel;
    if ([ChannelHandler sharedHandler].isHost) {
        newChannel = [self.activeChannelInfo geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    else{
        newChannel = [self.activeChannelInfo getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
        
    }
    self.activeChannelInfo = newChannel;
//    [self updateUIForChatViewWithChannel:self.activeChannelInfo];
    
}

-(void) voiceMessageReceived:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received Voice Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE];
    NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];

    
    NSString *SoundfilePath;
    if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == 0) {
//        [[AudioFileHandler sharedHandler] removeAudio:[NSString stringWithFormat:@"%@.caf", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];
//        SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:[NSString stringWithFormat:@"%@.caf", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];
        
//        [[AudioFileHandler sharedHandler] removeAudio:recordedAudioSaveFileName];
        recordedAudioSaveFileNameInDocDir = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
        SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:recordedAudioSaveFileNameInDocDir];
    }
    else{

        SoundfilePath = [[AudioFileHandler sharedHandler] returnFilePathAfterAppendingData:audioDataFromBase64String toFileName:recordedAudioSaveFileNameInDocDir];
        
        if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]-1) {
//            SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:@"receieved.caf"];
            NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
            receivedSoundURL =soundFileURL2;
           

        }

    }
//    SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:base64EncodedVoiceData saveDataAsFileName:[NSString stringWithFormat:@"%@.caf", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];
//    NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
//    
//    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL2 error:nil];
//    
//    [player setDelegate:self];
//    [player play];


}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    [recorder stop];
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
//        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
//        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        
//        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"recordedFile1.caf"];
//        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
//        
//        NSString *base64StringForAudioFile = [[AudioFileHandler sharedHandler] bas64EncodedStringFromAudioFileDataWithFileName:@"recordedFile1.caf"];
//        NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64StringForAudioFile options:1];
//        NSString *SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:@"2578.caf"];
//        NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
//        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:recordedAudioSaveFileNameInDocDir];
        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
        
        NSString *base64StringForAudioFile = [[AudioFileHandler sharedHandler] bas64EncodedStringFromAudioFileDataWithFileName:recordedAudioSaveFileNameInDocDir];
        NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64StringForAudioFile options:1];
        NSString *SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:recordedAudioSaveFileNameInDocDir];
        NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
        
       
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL2 error:nil];

//        [player setDelegate:self];
        [player play];
    }
}

- (IBAction)sendVoiceToChannelMembers:(id)sender {
    
    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] voiceMessageJSONStringInChunksWithAudioFileName:@"recordedFile1.caf"];
    
    for (int i= 0; i<self.activeChannelInfo.channelMemberIPs.count; i++) {
        if (![[self.activeChannelInfo.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
            for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
                [[asyncUDPConnectionHandler sharedHandler]sendMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
            }
        }
        
    }
}

- (IBAction)playRecordedSound:(id)sender {
//    OSStatus AudioQueueRemovePropertyListener ( AudioQueueRef inAQ, AudioQueuePropertyID inID, AudioQueuePropertyListenerProc inProc, void *inUserData );
//    [recorder stop];
//    [player stop];
//    player = nil;
//    OSStatus AudioQueueFlush ( AudioQueueRef inAQ );
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:receivedSoundURL error:nil];
    
    [player setDelegate:self];
    [player prepareToPlay];
    [player play];

}





#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
    NSData *recordedAudioFileData = [[AudioFileHandler sharedHandler] dataFromAudioFile:recordedAudioFileName];
    NSString *savedFilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:recordedAudioFileData saveDataAsFileName:@"recordedFile1.caf"];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


//- (AVAudioSessionPortDescription*)bluetoothAudioDevice
//{
//    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
//    return [self audioDeviceFromTypes:bluetoothRoutes];
//}
//
//- (AVAudioSessionPortDescription*)builtinAudioDevice
//{
//    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInMic];
//    return [self audioDeviceFromTypes:builtinRoutes];
//}
//
//- (AVAudioSessionPortDescription*)speakerAudioDevice
//{
//    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInSpeaker];
//    return [self audioDeviceFromTypes:builtinRoutes];
//}
//
//- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
//{
//    NSArray* routes = [[AVAudioSession sharedInstance] availableInputs];
//    for (AVAudioSessionPortDescription* route in routes)
//    {
//        if ([types containsObject:route.portType])
//        {
//            return route;
//        }
//    }
//    return nil;
//}
//
//#pragma mark switchAudioRoutes
//
//- (BOOL)switchBluetooth:(BOOL)onOrOff
//{
//    NSError* audioError = nil;
//    BOOL changeResult = NO;
//    if (onOrOff == YES)
//    {
//        AVAudioSessionPortDescription* _bluetoothPort = [self bluetoothAudioDevice];
//        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort
//                                                                    error:&audioError];
//    }
//    else
//    {
//        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
//        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort
//                                                                    error:&audioError];
//    }
//    return changeResult;
//}
//
//- (BOOL)switchSpeaker:(BOOL)onOrOff
//{
//    NSError* audioError = nil;
//    BOOL changeResult = NO;
//    if (onOrOff == YES)
//    {
//        changeResult = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
//                                                                          error:&audioError];
//    }
//    else
//    {
//        AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
//        changeResult = [[AVAudioSession sharedInstance] setPreferredInput:builtinPort
//                                                                    error:&audioError];
//    }
//    return changeResult;
//}
//
//- (BOOL)switchEarphone:(BOOL)onOrOff
//{
//    return [self switchSpeaker:!onOrOff];
//}

//#pragma mark fileHandlers
//
//-(NSArray *)findFiles:(NSString *)extension
//{
//    NSMutableArray *matches = [[NSMutableArray alloc]init];
//    NSFileManager *manager = [NSFileManager defaultManager];
//    
//    NSString *item;
//    NSArray *contents = [manager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
//    for (item in contents)
//    {
//        if ([[item pathExtension]isEqualToString:extension])
//        {
//            [matches addObject:item];
//        }
//    }
//    
//    return matches;
//}
//
//
//- (void)removeAudio:(NSString *)filename
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
//    NSError *error;
//    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
//    if (success) {
//        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removedSuccessFullyAlert show];
//    }
//    else
//    {
//        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
//    }
//}
//
//
//-(NSDate *)getFileCreationDateOfFile:(NSString *)fileName{
//    NSFileManager* fm = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
//
//    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
//    NSDate *creationDate;
//    if (attrs != nil) {
//        creationDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
//        NSLog(@"Date Created: %@", [creationDate description]);
//        return creationDate;
//    }
//    else {
//        NSLog(@"Not found");
//        return nil;
//    }
//    
//}
//
//
//-(NSData *)dataFromAudioFile:(NSString *)fileName{
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
//    
//    NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
//    NSData *myData = [NSData dataWithContentsOfURL:soundFileURL];
//    
//    return myData;
//}
//
//-(NSString *)saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:(NSData *)audioData saveDataAsFileName:(NSString *)fileName{
////    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
////    
////    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
////    NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
////
////    [audioData writeToURL:soundFileURL atomically:YES];
////    return soundFileURL;
//    
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    docsDir = [dirPaths objectAtIndex:0];
//    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:fileName]];
//    [audioData writeToFile:databasePath atomically:YES];
//    return databasePath;
//    
//}
//
//- (NSString *)bas64EncodedStringFromAudioFileDataWithFileName: (NSString *)fileName {
//    
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
//    NSData *zipFileData = [NSData dataWithContentsOfFile:filePath];
//    
//    NSString *base64String = [zipFileData base64EncodedStringWithOptions:0];
//    
//    base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
//                                                           withString:@"_"];
//    
//    base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
//                                                           withString:@"-"];
//    return base64String;
//    
//    // Adding to JSON and upload goes here.
//}
//


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
