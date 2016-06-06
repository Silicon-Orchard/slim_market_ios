//
//  ChatViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChatViewController.h"
#import "JoinChannelViewController.h"
#import "RecordViewController.h"

@interface ChatViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *recordedFileName, *receivedFileName;
    NSURL *receivedSoundURL;
    NSMutableData *audioData;
    NSData *finalAudioData;
    int chunkCounter;
    BOOL _isStreaming, _isPlayingStream;
    AudioRecorderTest *queueRecorder;
    NSMutableArray *receivedAudioStreamContainerArray;
    
}
@end

@implementation ChatViewController
@synthesize stopButton, playButton, recordPauseButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    receivedAudioStreamContainerArray = [[NSMutableArray alloc] init];
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    [[asyncTCPConnectionHandler sharedHandler] createTCPSenderSocket];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelRequestReceived:) name:JOINCHANNEL_REQUEST_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageReceived:) name:CHATMESSAGE_RECEIVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelLeftMessageReceieved:) name:CHANNEL_LEFT_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceStreamReceivedInChat:) name:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil];

    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceived:) name:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceivedInTCP:) name:TCP_VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForRepeatVoiceMessagereceived:) name:UDP_VOICE_MESSAGE_REPEAR_REQUEST_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAudioStream) name:@"playAudioNotification" object:nil];



    
    
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

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    
    self.bottomSpaceForSendContainer.constant = height;
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.title = [NSString stringWithFormat:@"Channel ID %d", self.currentActiveChannel.channelID];
    self.sendButton.enabled = NO;
    self.audioReceivedButton.hidden = YES;

    
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];

}

-(void) viewWillDisappear:(BOOL)animated {

   
    if ([[self backViewController] isKindOfClass:[JoinChannelViewController class]]) {
        JoinChannelViewController *previousViewController = (JoinChannelViewController *)[self backViewController];
        previousViewController.isChatOpen = NO;
    }
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
        [self channelLeaveMessageSend];
//        [self.navigationController popViewControllerAnimated:NO];
    }
//    [self channelLeaveMessageSend];

}

-(UIViewController *)backViewController
{
    NSArray * stack = self.navigationController.viewControllers;
    
    return stack.lastObject;
}

-(void)updateUIForChatViewWithChannel:(Channel *)currentChatChannel{

    self.channelMemberListLabel.text =@"";

    for (int i = 0; i < currentChatChannel.channelMemberIPs.count; i++) {
        NSMutableString *members = [[NSMutableString alloc] initWithString:self.channelMemberListLabel.text];
        if (i==0) {
            if (currentChatChannel.channelID ==1 || currentChatChannel.channelID ==2) {
                [members appendString:[NSString stringWithFormat:@"\n%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];

            }
            else{
                [members appendString:[NSString stringWithFormat:@"%@ Owner", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
            }
        }
        else{
            [members appendString:[NSString stringWithFormat:@"\n%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
        }
        self.channelMemberListLabel.text = members;
     
    }
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;



}

-(void)updateUIForChatMessage:(NSString *)chatMessage{

    NSMutableString *newString = [[NSMutableString alloc] initWithString:self.chatViewLabel.text];
    [newString appendString:[NSString stringWithFormat:@"\n%@", chatMessage]];
    self.chatViewLabel.text = newString;

}


-(void)ScreenTapped{
    [self.view endEditing:YES];
    self.bottomSpaceForSendContainer.constant = 0;
}

-(void) chatMessageReceived:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received Chat Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    NSString *chatMessage = [jsonDict objectForKey:JSON_KEY_MESSAGE];
    NSString *senderName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
    NSString *FullChatMessage = [NSString stringWithFormat:@"%@:%@", senderName,chatMessage];
    [self updateUIForChatMessage:FullChatMessage];
}


-(void) joinChannelRequestReceived:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received native Channel joined notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
//    [self addNewChannelToChannelListForJoinedChannelWithChannelData:jsonDict];

    if (self.currentActiveChannel.channelID ==1 ||self.currentActiveChannel.channelID ==2) {
        [self notifyMyPresenceInPublicChannelToNewlyJoinedIP:jsonDict];
    }
    else{
        [self addNewChannelToChannelListForJoinedChannelWithChannelData:jsonDict];

    }
    
}

-(void) ChannelLeftMessageReceieved:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received chat left notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    Channel *currentlyActiveChannel;
    
    if ([ChannelHandler sharedHandler].isHost) {
        currentlyActiveChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    else{
        currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    NSString *leftMemberIP;
    NSString *leftMemberName;

    if ([currentlyActiveChannel.foreignChannelHostIP isEqualToString:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]]) {
        [self.currentActiveChannel removeChannelWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if (currentlyActiveChannel.channelID == [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]) {
            for (int i = 0; i < currentlyActiveChannel.channelMemberIPs.count; i++) {
                NSString *memberIP = [currentlyActiveChannel.channelMemberIPs objectAtIndex:i];
                if ([memberIP isEqualToString:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]]) {
                    leftMemberIP = [[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] copy];
                    leftMemberName = [[currentlyActiveChannel.channelMemberNamess objectAtIndex:i] copy];
                    
                    [currentlyActiveChannel.channelMemberIPs removeObjectAtIndex:i];
                    [currentlyActiveChannel.channelMemberNamess removeObjectAtIndex:i];
                }
                [self.currentActiveChannel replaceForeignChannelOfID:[ChannelHandler sharedHandler].currentlyActiveChannelID withChannel:currentlyActiveChannel];
                [self.currentActiveChannel replaceChannelOfID:[ChannelHandler sharedHandler].currentlyActiveChannelID withChannel:currentlyActiveChannel];
                self.currentActiveChannel = currentlyActiveChannel;
            }
            [self updateUIForChatViewWithChannel:currentlyActiveChannel];
            [self updateUIForChatMessage:[NSString stringWithFormat:@"%@ has left!",leftMemberName]];
        }
        
    }
    
    
}

-(void) channelUpdated:(NSNotification*)notification{
    Channel *newChannel;
    if ([ChannelHandler sharedHandler].isHost) {
        newChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    else{
        newChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];

    }
    self.currentActiveChannel = newChannel;
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];

}

-(void)addNewChannelToChannelListForJoinedChannelWithChannelData:(NSDictionary *)channelData{
    
    Channel *blankChannel = [[Channel alloc] init];
    [blankChannel addUserToChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
//    if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==1 || [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==2) {
//       
//    }
    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] confirmJoiningForChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:[channelData objectForKey:JSON_KEY_DEVICE_NAME]];
    
    Channel *currentlyActiveChannel = [blankChannel geChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
    
    for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
        if (i!=0) {
            [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
        }
       
    }
    
//    [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
     [self updateUIForChatViewWithChannel:self.currentActiveChannel];
    
}

-(void)notifyMyPresenceInPublicChannelToNewlyJoinedIP:(NSDictionary *)channelData{
    
    Channel *blankChannel = [[Channel alloc] init];
    [blankChannel addUserToForeignChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] confirmJoiningForChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:self.currentActiveChannel.channelMemberNamess[0]];
    [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
//    Channel *currentlyactiveChannel = self.currentActiveChannel;

}




- (IBAction)SendButtonTapped:(id)sender {
    
   
    
    Channel *currentlyActiveChannel;
    if ([ChannelHandler sharedHandler].isHost) {
        currentlyActiveChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    else{
        currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
        
    }
    NSString *chatMessageToSend = [[MessageHandler sharedHandler] createChatMessageWithChannelID:[ChannelHandler sharedHandler].currentlyActiveChannelID  deviceName:[ChannelHandler sharedHandler].userNameInChannel chatmessage:self.chatTextField.text];
//    if ([ChannelHandler sharedHandler].currentlyActiveChannelID ==1 || [ChannelHandler sharedHandler].currentlyActiveChannelID ==2) {
//
//        [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
//
//
//        for (int i =1 ; i<=254; i++) {
//            NSString *ipAddressTosendData = [NSString stringWithFormat:@"%@%d",[[NSUserDefaults standardUserDefaults] objectForKey:IPADDRESS_FORMATKEY],i];
//            if (![ipAddressTosendData isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                [[asyncUDPConnectionHandler sharedHandler]sendMessage:chatMessageToSend toIPAddress:ipAddressTosendData];
//            }
//            
//        }
//        
//    }
//    else{
//        for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
//            if (![[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                [[asyncUDPConnectionHandler sharedHandler]sendMessage:chatMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
//            }
//            
//        }
//    
//    }
    for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
        if (![[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//            [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:chatMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
                        [[asyncUDPConnectionHandler sharedHandler]sendMessage:chatMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];

        }
        
    }
   
    NSString *chatMessage = self.chatTextField.text;
    NSString *senderName = [ChannelHandler sharedHandler].userNameInChannel;
    NSString *FullChatMessage = [NSString stringWithFormat:@"%@:%@", senderName,chatMessage];
    [self updateUIForChatMessage:FullChatMessage];
    
    

    
    
}

-(void)channelLeaveMessageSend{

    Channel *currentlyActiveChannel;
    if ([ChannelHandler sharedHandler].isHost) {
        currentlyActiveChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
    }
    else{
        currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
        
    }
   
    NSString *leaveMessageToSend = [[MessageHandler sharedHandler] leaveChatMessageWithChannelID:[ChannelHandler sharedHandler].currentlyActiveChannelID  deviceName:[ChannelHandler sharedHandler].userNameInChannel];
    for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
        if (![[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
            [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
        }
        
    }
    [self.currentActiveChannel removeChannelWithChannelID:currentlyActiveChannel.channelID];


}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)voiceTapped:(id)sender {
    
    self.voiceMailView.hidden = NO;
    
}
- (IBAction)closeTappedOnVoiceMailView:(id)sender {
    if (self.thePlayer.isPlaying) {
        [self.thePlayer stop];
    }
    if (recorder.isRecording) {
        [recorder stop];
    }
    self.voiceMailView.hidden = YES;
}

-(void)requestForRepeatVoiceMessagereceived:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    //    NSLog (@"Successfully received Voice Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] voiceMessageJSONStringInChunksWithAudioFileName:@"MyAudioMemo.m4a" inChannel:self.currentActiveChannel.channelID];
    for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
        NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
        //                    [NSThread sleepForTimeInterval:0.09];
        [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
    }
}

-(void)voiceMessageReceivedInTCP:(NSNotification *) notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE];
    NSData *audioData = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];
    receivedFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
    if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] integerValue] == self.currentActiveChannel.channelID) {
        
    }
    NSString *SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:audioData saveDataAsFileName:receivedFileName];
    NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
    receivedSoundURL =soundFileURL2;
    [self updateUIForChatMessage:[NSString stringWithFormat:@"Message Received From %@",[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];

    [self.audioReceivedButton setTitle:[NSString stringWithFormat:@"Play received %@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]] forState:UIControlStateNormal];
    self.audioReceivedButton.hidden = NO;

}

-(void) voiceMessageReceived:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
//    NSLog (@"Successfully received Voice Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE];
    NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];
    NSLog(@"Received Data: voiceMessage\npacket count %d\ntotalPacket %d", [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue], [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]);
    NSString *SoundfilePath;
    
    if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == 1) {
        finalAudioData = nil;
        audioData = nil;
        chunkCounter = 1;
        audioData = [[NSMutableData alloc] initWithData:audioDataFromBase64String];
        receivedFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
       
        
        
    }
    else{
        chunkCounter ++;
        [audioData appendData:audioDataFromBase64String];
        //        SoundfilePath = [[AudioFileHandler sharedHandler] returnFilePathAfterAppendingData:audioDataFromBase64String toFileName:receivedFileName];
        
        if ([[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue] == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]) {
            if (chunkCounter == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]) {
                
                [self updateUIForChatMessage:[NSString stringWithFormat:@"Message Received From %@",[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];
                //            NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
                //            receivedSoundURL =soundFileURL2;
                finalAudioData = [[NSData alloc] initWithData:audioData];
                SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:finalAudioData saveDataAsFileName:receivedFileName];
                NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
                receivedSoundURL =soundFileURL2;
                //            self.audioReceivedButton.titleLabel.text = [NSString stringWithFormat:@"%@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
                [self.audioReceivedButton setTitle:[NSString stringWithFormat:@"Play received %@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]] forState:UIControlStateNormal];
                self.audioReceivedButton.hidden = NO;
                [self updateUIForChatMessage:[NSString stringWithFormat:@"packet arrived %d/%d",chunkCounter,[[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]]];
                chunkCounter = 0;
                
            }
            else{
                NSString *repeatMessageRequestJSON = [[MessageHandler sharedHandler] repeatVoiceMessageRequest];
                [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:repeatMessageRequestJSON toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];

            }
        }
//        if (chunkCounter == [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]) {
//
//            [self updateUIForChatMessage:[NSString stringWithFormat:@"Message Received From %@",[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]]];
//            finalAudioData = [[NSData alloc] initWithData:audioData];
//            SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:finalAudioData saveDataAsFileName:receivedFileName];
//            NSURL *soundFileURL2 = [NSURL fileURLWithPath:SoundfilePath];
//            receivedSoundURL =soundFileURL2;
//            //            self.audioReceivedButton.titleLabel.text = [NSString stringWithFormat:@"%@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
//            [self.audioReceivedButton setTitle:[NSString stringWithFormat:@"Play received %@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]] forState:UIControlStateNormal];
//            self.audioReceivedButton.hidden = NO;
//            chunkCounter = 0;
//            
//        }
        
       
        
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
    
//    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] voiceMessageJSONStringInChunksWithAudioFileName:recordedFileName];
//    
//    for (int i= 0; i<self.currentActiveChannel.channelMemberIPs.count; i++) {
//        if (![[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//            //            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
//            for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
//                NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
//                [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i]];
//            }
//        }
//        
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Voice Message Sent to Channel Members!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    
    self.sendButton.enabled = NO;
    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] voiceMessageJSONStringInChunksWithAudioFileName:recordedFileName inChannel:self.currentActiveChannel.channelID];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Data To send\npacket count %d", voiceMessagechunkStrings.count);

        for (int i= 0; i<self.currentActiveChannel.channelMemberIPs.count; i++) {
            if (![[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                //            [[asyncUDPConnectionHandler sharedHandler]sendMessage:voiceMessageToSend toIPAddress:[self.activeChannelInfo.channelMemberIPs objectAtIndex:i]];
                for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
                    NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
                    if (j%5 == 0) {
                         [NSThread sleepForTimeInterval:0.09];
                    }
//                    [NSThread sleepForTimeInterval:0.09];
                    [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i]];
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                            message: [NSString stringWithFormat:@"Sent packet count %lu", (unsigned long)voiceMessagechunkStrings.count] //@"Voice Message Sent to Channel Members!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            
            [alert show];
            self.sendButton.enabled = YES;
            [self updateUIForChatMessage:@"My Voice Message is Sent"];

        });
    });
    
//    NSString *voiceMessageJSONStringForTCP = [[MessageHandler sharedHandler] voiceMessageJSONStringWithAudioFileName:recordedFileName forChannel:self.currentActiveChannel.channelID];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        
//        for (int i= 0; i<self.currentActiveChannel.channelMemberIPs.count; i++) {
//            if (![[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [[asyncTCPConnectionHandler sharedHandler] sendAudioData:[voiceMessageJSONStringForTCP dataUsingEncoding:NSUTF8StringEncoding] toHost:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] toPort:WALKIETALKIE_TCP_SENDER];
//
//                });
////                [[asyncTCPConnectionHandler sharedHandler] sendAudioData:[voiceMessageJSONStringForTCP dataUsingEncoding:NSUTF8StringEncoding] toHost:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] toPort:WALKIETALKIE_TCP_SENDER];
//            }
//            
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                            message: @"Voice Mail Sent To Channel Members!" //[NSString stringWithFormat:@"Voice Mail : %lu", [voiceMessageJSONStringForTCP dataUsingEncoding:NSUTF8StringEncoding].length]
//                                                           delegate: nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            
//            
//            //            [NSThread sleepForTimeInterval:0.01];
//            [alert show];
//            self.sendButton.enabled = YES;
//        });
//    
//    });

    
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
        
//                self.thePlayer = [[AVAudioPlayer alloc] initWithData:finalAudioData error:&error];
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

-(void) voiceStreamReceivedInChat:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    if (_isStreaming) {
        if (![[AudioRecorderTest_StreamPlayer sharedHandler] isPlayerRunning]) {
            [[AudioRecorderTest_StreamPlayer sharedHandler] startMediaPlayer];
        }
        [[AudioRecorderTest_StreamPlayer sharedHandler] enqueueBufferWithAudioData:receivedData];
    }
//    [[AudioRecorderTest_StreamPlayer sharedHandler] enqueueBufferWithAudioData:receivedData];
//    [receivedAudioStreamContainerArray addObject:receivedData];
//    [self playAudioStream];

    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"playAudioNotification" object:nil];
//    
//    if (!_isPlayingStream) {
////        [[NSNotificationCenter defaultCenter] postNotificationName:@"playAudioNotification" object:nil];
//        [self playAudioStream];
//        _isPlayingStream = YES;
//    }
}

-(void)playAudioStream{
//    NSError *error = nil;
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setActive:YES error:nil];
//    self.thePlayer = [[AVAudioPlayer alloc] initWithData:[receivedAudioStreamContainerArray objectAtIndex:0] error:&error];
//    if (error) {
//        NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
//    }
//    else {
//        [ self.thePlayer setDelegate:self];
//        [ self.thePlayer setNumberOfLoops:0];
//        [ self.thePlayer prepareToPlay];
//        [ self.thePlayer play];
//    }
//    [receivedAudioStreamContainerArray removeObjectAtIndex:0];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.thePlayer stop];
//    if (receivedAudioStreamContainerArray.count > 0) {
//        [receivedAudioStreamContainerArray removeObjectAtIndex:0];
//        [self playAudioStream];
//    }
//    else{
//        _isPlayingStream = NO;
//    }
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

- (IBAction)voiceStreamButtonTapped:(id)sender {
    
    if (_isStreaming) {
        [self.voiceStreamerButton setTitle:@"Start Streaming" forState:UIControlStateNormal];
        [queueRecorder stopRecording];
        [[AudioRecorderTest_StreamPlayer sharedHandler] stopMediaPlayer];

        queueRecorder = nil;
        _isStreaming = NO;
        
    }
    else{
        _isStreaming = YES;
        queueRecorder =  [[AudioRecorderTest alloc] init];
        [queueRecorder startRecording];
//        [[AudioRecorderTest_StreamPlayer sharedHandler] startMediaPlayer];
//        [queueRecorder startMediaPlayer];
        [self.voiceStreamerButton setTitle:@"Stop Streaming" forState:UIControlStateNormal];
        
    }

    
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"voiceMessageSegue"]) {
        RecordViewController *recordControl = segue.destinationViewController;
        recordControl.activeChannelInfo = self.currentActiveChannel;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
