//
//  RecordViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/6/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "RecordViewController.h"


@interface RecordViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *recordedFileName, *receivedFileName;
    NSURL *receivedSoundURL;
    NSMutableData *audioData;
    NSData *finalAudioData;
}

@end

@implementation RecordViewController
@synthesize stopButton, playButton, recordPauseButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable Stop/Play button when application launches
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceived:) name:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];

    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error];
    if (error) {
        NSLog(@"Record Couldn't Start . Error %@", [error localizedDescription]);
    }
    else{
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
    }
   
}

-(void)viewWillAppear:(BOOL)animated{
    self.sendButton.enabled = NO;
    self.audioReceivedButton.enabled = NO;
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
        finalAudioData = nil;
        audioData = nil;
        audioData = [[NSMutableData alloc] initWithData:audioDataFromBase64String];
//        [[AudioFileHandler sharedHandler] removeAudio:receivedFileName];
        receivedFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
//        SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioDataFromBase64String saveDataAsFileName:receivedFileName];

//        receivedFileName = @"receivedFile.caf";
        
        
    }
    else{
        [audioData appendData:audioDataFromBase64String];
//        SoundfilePath = [[AudioFileHandler sharedHandler] returnFilePathAfterAppendingData:audioDataFromBase64String toFileName:receivedFileName];
        
        if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]-1) {
            
//            NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
//            receivedSoundURL =soundFileURL2;
            finalAudioData = [[NSData alloc] initWithData:audioData];
            SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:finalAudioData saveDataAsFileName:receivedFileName];
            NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
            receivedSoundURL =soundFileURL2;
//            self.audioReceivedButton.titleLabel.text = [NSString stringWithFormat:@"%@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
            [self.audioReceivedButton setTitle:[NSString stringWithFormat:@"%@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]] forState:UIControlStateNormal];
            self.audioReceivedButton.enabled = YES;


        }
        
    }
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
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
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:recordedFileName];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        NSString* foofile = [documentsPath stringByAppendingPathComponent:recordedFileName];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
        if (!fileExists) {
            NSLog(@"File Doesn't Exist!");
        }

        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        self.thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
//        AVPlayer *newPlayer = [[AVPlayer alloc] initWithURL:soundFileURL];
        if (error) {
            NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
        }
        else {
            [self.thePlayer setDelegate:self];
            [self.thePlayer play];
        }
       
    }
}

- (IBAction)sendTapped:(id)sender {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];

    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] voiceMessageJSONStringInChunksWithAudioFileName:recordedFileName];
    
    for (int i= 0; i<self.activeChannelInfo.channelMemberIPs.count; i++) {
        if (![[self.activeChannelInfo.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
            //            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
            for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
                NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
                [[asyncUDPConnectionHandler sharedHandler]sendMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
            }
        }
        
    }
    
}



- (IBAction)playReceivedSound:(id)sender {
    
    if (!recorder.recording){
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:receivedFileName];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (!fileExists) {
            NSLog(@"File Doesn't Exist!");
            return;
        }
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        self.thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:receivedSoundURL error:&error];
//        if (error) {
//            NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
//        }
//        else {
//            [player setDelegate:self];
//            [player play];
//        }
        
//        self.thePlayer = [[AVAudioPlayer alloc] initWithData:finalAudioData error:&error];
        if (error) {
            NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
        }
        else {
            [self.thePlayer setDelegate:self];
            [self.thePlayer setNumberOfLoops:0];
            [self.thePlayer prepareToPlay];
            [self.thePlayer play];
        }
//
//        AVPlayer *newPlayer = [[AVPlayer alloc] initWithURL:receivedSoundURL];
//        [newPlayer play];

        
    }
    else{
        NSLog(@"Recorder Active For some reason!");
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
    recordedFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
    NSData *recordedAudioFileData = [[AudioFileHandler sharedHandler] dataFromAudioFile:@"MyAudioMemo.m4a"];
    NSString *savedFilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:recordedAudioFileData saveDataAsFileName:recordedFileName];
    self.sendButton.enabled = YES;
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.thePlayer stop];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog( @"decode Error !");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
