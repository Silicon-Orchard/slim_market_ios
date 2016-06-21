//
//  ChatViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChatViewController.h"
#import "JoinChannelViewController.h"
//#import "RecordViewController.h"
#import "IncomingMessageCell.h"
#import "OutGoingMessagesCell.h"
#import "channelMemberActivityTableViewCell.h"

#define VoiceMessageSign @"voice&^%"

#define MesssageType_Text_Me        @(0)
#define MesssageType_Text_Other     @(1)
#define MesssageType_Voice_Me       @(2)
#define MesssageType_Voice_Other    @(3)
#define MesssageType_Left_Channel    @(4)


@interface ChatViewController (){
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSString *recordedFileName, *receivedFileName;
    
    NSMutableArray * recordedAudioFileNames;
    NSMutableArray * receivedAudioFileNames;
    
    NSMutableDictionary * audioFileNamesDic;
    NSMutableDictionary * receivedAudioDic;
    
    
    NSURL *receivedSoundURL;
    NSMutableData *audioData;
    NSData *finalAudioData;
    int chunkCounter;
    BOOL _isStreaming, _isPlayingStream;
    AudioRecorderTest *queueRecorder;
    NSMutableArray *receivedAudioStreamContainerArray;
    NSMutableArray *chatRoomMemberList, *chatMessageList;
    
    BOOL addingVoiceMessage;
}


@property (nonatomic, strong) IncomingMessageCell *prototypeCell;
@end

@implementation ChatViewController
//@synthesize playButton, recordPauseButton;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    addingVoiceMessage = NO;
    recordedAudioFileNames = [[NSMutableArray alloc] init];
    receivedAudioFileNames = [[NSMutableArray alloc] init];
    audioFileNamesDic = [NSMutableDictionary new];
    
    chatMessageList = [[NSMutableArray alloc] init];
    chatRoomMemberList = [[NSMutableArray alloc] init];
    receivedAudioStreamContainerArray = [[NSMutableArray alloc] init];
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    
    chunkCounter = 0;
    
    
    //Emergency UI Update
    if(self.isPersonalChannel){
        
        [self updateUIForPersonalMessage];
    }else{
        
        [self updateUIForChatViewWithChannel:self.currentActiveChannel];
    }
    
    [self initWithNotification];
    [self initWithConfig];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    aTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:aTap];
    
    [self.playButton setEnabled:NO];

    [self.chatTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];



    
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setNavigationItemTitle];
    
    self.sendButton.enabled = NO;
    //self.audioReceivedButton.hidden = YES;
    
    self.popupBoxView.layer.cornerRadius = 10;
    self.popupBoxView.layer.masksToBounds = YES;
    
    
    self.navigationController.navigationBar.topItem.title = @"Back";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE0362B);

}

-(void)viewDidAppear:(BOOL)animated{
    
    if(!self.isPersonalChannel){
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.frame.size.height)];
        //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:chatMessageList.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated {

    
    if (self.isPersonalChannel) {
        
        
    }
   
    if ([[self backViewController] isKindOfClass:[JoinChannelViewController class]]) {
        JoinChannelViewController *previousViewController = (JoinChannelViewController *)[self backViewController];
        previousViewController.isChatOpen = NO;
    }
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // Navigation button was pressed.
        
        [self channelLeaveMessageSend];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.chatTableView removeObserver:self forKeyPath:@"contentSize"];
    [[FileHandler sharedHandler] deleteWalkieTalkieDirectory];
    
    
    if(self.isPersonalChannel){
        NSLog(@"removing Oponent User from accepted list");
        [[ChannelHandler sharedHandler] removeOponetUserFromAcceptedList:self.oponentUser];
    }
    
}


#pragma mark - Helpers

-(void)initWithNotification {

    //UDP Response Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelRequestReceived:) name:JOINCHANNEL_REQUEST_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageReceived:) name:CHATMESSAGE_RECEIVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelLeftMessageReceieved:) name:CHANNEL_LEFT_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceStreamReceivedInChat:) name:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceived:) name:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForRepeatVoiceMessagereceived:) name:UDP_VOICE_MESSAGE_REPEAR_REQUEST_NOTIFICATIONKEY object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileMessageReceived:) name:FILE_RECEIEVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileRepeatRequestReceived:) name:FILE_REPEAT_REQUEST_NOTIFICATIONKEY object:nil];


    
    if(self.isPersonalChannel){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatDeclined:) name:ONE_TO_ONE_CHAT_DECLINE_NOTIFICATIONKEY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatAcceptFromStartPage:) name:ONE_TO_ONE_CHAT_ACCEPT_FROM_STARTPAGE_NOTIFICATIONKEY object:nil];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

-(void)initWithConfig {
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    

    
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
    
    // Setup equalizerImage
    self.equalizerImage.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"recoring-timeline"],
                                           [UIImage imageNamed:@"recoring-timeline2"],
                                           [UIImage imageNamed:@"recoring-timeline3"],
                                           nil];
    self.equalizerImage.animationDuration = 0.3;
    // How many times to repeat the animation (0 for indefinitely).
    self.equalizerImage.animationRepeatCount = 0;
    
    
//    self.channelMemberTableView.backgroundView = [UIView new];
//    self.channelMemberTableView.backgroundView.backgroundColor = [UIColor clearColor];
//    
//    self.chatTableView.backgroundView = [UIView new];
//    self.chatTableView.backgroundView.backgroundColor = [UIColor clearColor];
}

-(void)setNavigationItemTitle{
    
    if(self.isPersonalChannel){
        
        self.title = self.oponentUser.deviceName;
    }else{
        
        NSString *title;
        if(self.currentActiveChannel.channelID == 1){
            title = @"Public Channel A";
        }else if(self.currentActiveChannel.channelID == 2){
            title = @"Public Channel B";
        }else{
            title = [NSString stringWithFormat:@"Private Channel: %d", self.currentActiveChannel.channelID];
        }
        
        self.title = title;
    }
}

//- (void) addFooterToTableView:(UITableView *) myTableView
//{
//    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
//    
//    [myTableView setTableFooterView:v];
//}

-(UIViewController *)backViewController
{
    NSArray * stack = self.navigationController.viewControllers;
    
    return stack.lastObject;
}

-(void)channelLeaveMessageSend{
    
    int channelID = self.isPersonalChannel ? 0: [ChannelHandler sharedHandler].currentlyActiveChannelID;
    NSString *deviceName = self.isPersonalChannel ? self.oponentUser.deviceName : [ChannelHandler sharedHandler].userNameInChannel;
    
    NSString *leaveMessageToSend = [[MessageHandler sharedHandler] leaveChatMessageWithChannelID:channelID  deviceName:deviceName];
    
    if(self.isPersonalChannel){
        
        [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:self.oponentUser.deviceIP];
        
    }else{
        
        Channel *currentlyActiveChannel;
        if ([ChannelHandler sharedHandler].isHost) {
            currentlyActiveChannel = [self.currentActiveChannel geChannel:channelID];
        }
        else{
            currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:channelID];
            
        }
        
        for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
            
            if (![[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                
                [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
            }
            
        }
        [self.currentActiveChannel removeChannelWithChannelID:currentlyActiveChannel.channelID];
    }
    
}

#pragma mark - UIHelpers

-(void)updateUIForChatViewWithChannel:(Channel *)currentChatChannel{

    chatRoomMemberList = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentChatChannel.channelMemberIPs.count; i++) {
        if (i==0) {
            if (currentChatChannel.channelID ==1 || currentChatChannel.channelID ==2) {

                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
            }
            else{

                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Owner", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
            }
        }
        else{

            [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
        }

    }
    
    [self.channelMemberTableView reloadData];
}

-(void)updateUIForPersonalMessage{
    
    [chatRoomMemberList addObject:self.oponentUser.deviceName];
    
    //self.topSpaceConstraintOfChatTable = 0;
    self.heightConstraintchatMemberTable.constant = 60.0f;
    [self.view layoutIfNeeded];
    
//    self.memberTableContainerView.hidden = YES;
//    self.channelMemberTableView.delegate =nil;
//    self.channelMemberTableView.dataSource = nil;
//    self.channelMemberTableView.hidden = YES;
}

-(void)updateUIForChatMessage:(NSDictionary *)messageDic {
    
    [chatMessageList addObject:messageDic];
    
    NSIndexPath * indexPathOfYourCell = [NSIndexPath indexPathForRow:([chatMessageList count] -1) inSection:0];
    
    [self.chatTableView beginUpdates];
    [self.chatTableView insertRowsAtIndexPaths:@[indexPathOfYourCell] withRowAnimation:UITableViewRowAnimationNone];
    [self.chatTableView endUpdates];
    
    [self.chatTableView scrollToRowAtIndexPath:indexPathOfYourCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)startImageEqualizer{
    
    [self.equalizerImage stopAnimating];
    [self.equalizerImage startAnimating];
}

-(void)stopImageEqualizer{
    
    [self.equalizerImage stopAnimating];
}



#pragma mark - IBAction

- (IBAction)SendButtonTapped:(id)sender {
    
    int channelID;
    NSString *deviceName;
    if(self.isPersonalChannel){
        
        if(!self.oponentUser.isActive){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Rechable"
                                                            message: [NSString stringWithFormat:@"%@ is not reachable right now & won't be abble to receive message.", self.oponentUser.deviceName]
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            
            [alert show];
            return;
        }
        
        channelID = 0;
        deviceName = self.oponentUser.deviceName;
        
    }else{
        channelID = [ChannelHandler sharedHandler].currentlyActiveChannelID;
        deviceName = [ChannelHandler sharedHandler].userNameInChannel;
    }

    NSString *chatMessageToSend = [[MessageHandler sharedHandler] createChatMessageWithChannelID:channelID  deviceName:deviceName chatmessage:self.chatTextField.text];
    
    if(self.isPersonalChannel){
        //send message
        [[asyncUDPConnectionHandler sharedHandler]sendMessage:chatMessageToSend toIPAddress:self.oponentUser.deviceIP];
        
    } else {
        
        Channel *currentlyActiveChannel;
        if ([ChannelHandler sharedHandler].isHost) {
            currentlyActiveChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
        }
        else{
            currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
            
        }
        //send message to All
        for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
            if (![[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                
                [[asyncUDPConnectionHandler sharedHandler]sendMessage:chatMessageToSend toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
                
            }
        }
    }
    

    NSDictionary *messageDic = @{
                                 @"type": MesssageType_Text_Me,
                                 @"sender": @"Me",
                                 @"message": self.chatTextField.text
                                 };
    [self updateUIForChatMessage:messageDic];
    
    self.chatTextField.text = @"";
    //[self.chatTextField becomeFirstResponder];
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
        [self.recordPauseButton setBackgroundImage:[UIImage imageNamed:@"Record Stop"] forState:UIControlStateNormal];
        [self startImageEqualizer];
        
    } else {
        
        // stop recording
        [recorder stop];
        [self.recordPauseButton setBackgroundImage:[UIImage imageNamed:@"Record srt"] forState:UIControlStateNormal];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [self stopImageEqualizer];
    }
    
    [self.playButton setEnabled:NO];
}


- (IBAction)playTapped:(id)sender {
    
    if (!recorder.recording){
        
        NSLog(@"recordedAudioFileNames Count: %d", [recordedAudioFileNames count]);
        NSString * fileName = [recordedAudioFileNames lastObject];
        
        NSString *audioFilePath = [[FileHandler sharedHandler] pathToFileWithFileName:fileName OfType:kFileTypeAudio];
        //[[AudioFileHandler sharedHandler] getAudioFilePathOfFilaName:[recordedAudioFileNames lastObject]];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:audioFilePath];
        NSError *error = nil;
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
        if (!fileExists) {
            NSLog(@"File Doesn't Exist!");
        }
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        self.thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        
        if (error) {
            
            NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
        } else {
            
            [self.thePlayer setDelegate:self];
            [self.thePlayer play];
            [self startImageEqualizer];
        }
        
    }
}

- (IBAction)sendTapped:(id)sender {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    
    self.sendButton.enabled = NO;
    NSString *audioFileName = [recordedAudioFileNames lastObject];
    
    int channelID = self.isPersonalChannel ? 0 :self.currentActiveChannel.channelID;
    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] jsonStringArrayWithFile:audioFileName OfType:kFileTypeAudio inChannel:channelID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Data To send\npacket count %lu", (unsigned long)voiceMessagechunkStrings.count);
        
        if (self.isPersonalChannel) {
            
            for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
                NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
                if (j%5 == 0) {
                    [NSThread sleepForTimeInterval:0.09];
                }
                [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:self.oponentUser.deviceIP];
            }
            
        }else {
            
            for (int i= 0; i<self.currentActiveChannel.channelMemberIPs.count; i++) {
                if (![[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                    for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
                        NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
                        if (j%5 == 0) {
                            [NSThread sleepForTimeInterval:0.09];
                        }
                        //                    [NSThread sleepForTimeInterval:0.09];
                        [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i]];
                    }
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
            
            // voice message
            NSDictionary *messageDic = @{
                                         @"type": MesssageType_Voice_Me,
                                         @"sender": @"Me",
                                         @"message": @"sent a voice message ▶️"
                                         };
            [self updateUIForChatMessage:messageDic];
        });
    });
    
}

- (IBAction)voiceStreamButtonTapped:(id)sender {
    
    if (_isStreaming) {

        
        [queueRecorder stopRecording];
        [[AudioRecorderTest_StreamPlayer sharedHandler] stopMediaPlayer];
        
        queueRecorder = nil;
        _isStreaming = NO;
        [self stopImageEqualizer];
        [self.voiceStreamerButton setBackgroundImage:[UIImage imageNamed:@"Start Streaming Btn Normal"] forState:UIControlStateNormal];
    }
    else{
        _isStreaming = YES;
        
        queueRecorder =  [[AudioRecorderTest alloc] init];
        [queueRecorder startRecording];
        
        [self startImageEqualizer];
        [self.voiceStreamerButton setBackgroundImage:[UIImage imageNamed:@"Stop Streaming Btn normal"] forState:UIControlStateNormal];
    }

}


#pragma mark - Noticfication
#pragma mark Observer

-(void) chatMessageReceived:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received Chat Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSDictionary *messageDic = @{
                                 @"type": MesssageType_Text_Other,
                                 @"sender": [jsonDict objectForKey:JSON_KEY_DEVICE_NAME],
                                 @"message":[jsonDict objectForKey:JSON_KEY_MESSAGE]
                                 };
    [self updateUIForChatMessage:messageDic];
}


-(void) joinChannelRequestReceived:(NSNotification*)notification{
    
    if(self.isPersonalChannel) {
        
        
    }else{
        
        NSDictionary* userInfo = notification.userInfo;
        NSData* receivedData = (NSData*)userInfo[@"receievedData"];
        NSLog (@"Successfully received native Channel joined notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
        NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
        
        int requestChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
        
        if(self.currentActiveChannel.channelID == requestChannelID) {
        
            if (self.currentActiveChannel.channelID == 1 || self.currentActiveChannel.channelID == 2) {
                
                [self notifyMyPresenceInPublicChannelToNewlyJoinedIP:jsonDict];
            }
            else{
                [self addNewChannelToChannelListForJoinedChannelWithChannelData:jsonDict];
                
            }
        }
    }
}

-(void) ChannelLeftMessageReceieved:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received chat left notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    
    if(self.isPersonalChannel){
        
        
        NSLog(@"This user has left PersonalChannel!");
        
        User * leftUser = [[User alloc] initWithDictionary:jsonDict];
        [[ChannelHandler sharedHandler] setActive:NO toUser:leftUser];
        
        self.oponentUser.isActive = NO;
        [self.channelMemberTableView reloadData];

        
    }else {
        
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
                
                NSDictionary *messageDic = @{
                                             @"type": MesssageType_Left_Channel,
                                             @"sender": leftMemberName,
                                             @"message": @"has left!"
                                             };
                [self updateUIForChatMessage:messageDic];
                
                
                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ has left!",leftMemberName]];
                [self.channelMemberTableView reloadData];
            }
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
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
}

-(void)requestForRepeatVoiceMessagereceived:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    //    NSLog (@"Successfully received Voice Message notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    int channelID = self.isPersonalChannel ? 0 :self.currentActiveChannel.channelID;
    
#warning TODO: audioFileName name will be received request audioFileName
    NSString *audioFileName = [recordedAudioFileNames lastObject];
    NSArray *voiceMessagechunkStrings = [[MessageHandler sharedHandler] jsonStringArrayWithFile:audioFileName OfType:kFileTypeAudio inChannel:channelID];
    
    for (int j = 0; j<voiceMessagechunkStrings.count; j++) {
        NSLog(@"message to send %@", [voiceMessagechunkStrings objectAtIndex:j]);
        //                    [NSThread sleepForTimeInterval:0.09];
        [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:[voiceMessagechunkStrings objectAtIndex:j] toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
    }
}


-(void) voiceMessageReceived:(NSNotification*)notification{
    
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE];
    NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];
    
    int currentChunk  = [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK] intValue];
    int chunkCount = [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue];
    NSLog(@"Received Data: voiceMessage\npacket count %d\ntotalPacket %d",currentChunk, chunkCount);
    
    if (currentChunk == 1) {
        
        finalAudioData = nil;
        audioData = nil;
        chunkCounter = 1;
        audioData = [[NSMutableData alloc] initWithData:audioDataFromBase64String];
        receivedFileName = [NSString stringWithFormat:@"%d.caf",arc4random_uniform(20000)];
        
    }else {
        
        chunkCounter ++;
        [audioData appendData:audioDataFromBase64String];
        //        SoundfilePath = [[AudioFileHandler sharedHandler] returnFilePathAfterAppendingData:audioDataFromBase64String toFileName:receivedFileName];
        
        if (currentChunk == chunkCount) {
            if (chunkCounter == chunkCount) {
                

                
                finalAudioData = [[NSData alloc] initWithData:audioData];
                NSString * audioFileName = [jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_FILE_NAME];
                NSString *audioFolderPath = [[FileHandler sharedHandler] pathToFileFolderOfType:kFileTypeAudio];
                //saveAudioData
                
                NSString *audioFilePath = [[FileHandler sharedHandler] writeData:finalAudioData toFileName:audioFileName ofType:kFileTypeAudio];
                                           //saveAudioData:finalAudioData asFileName:audioFileName ofType:kFileTypeAudio];
                //NSString *SoundfilePath = [[AudioFileHandler sharedHandler] saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:finalAudioData saveDataAsFileName:receivedFileName];
                
                receivedSoundURL = [NSURL fileURLWithPath:audioFilePath];
                [receivedAudioFileNames addObject:audioFileName];
                
                
                NSLog(@"packet arrived %d/%d",chunkCounter, [[jsonDict objectForKey:JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT] intValue]);
                chunkCounter = 0;
                
                //
                //                [self.audioReceivedButton setTitle:[NSString stringWithFormat:@"Play received %@'s VoiceMail", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]] forState:UIControlStateNormal];
                //                self.audioReceivedButton.hidden = NO;
                
                // voice message
                NSDictionary *messageDic = @{
                                             @"type": MesssageType_Voice_Other,
                                             @"sender": [jsonDict objectForKey:JSON_KEY_DEVICE_NAME],
                                             @"message": @"sent a voice message ▶️"
                                             };
                [self updateUIForChatMessage:messageDic];
                
            } else{
                
                NSString *repeatMessageRequestJSON = [[MessageHandler sharedHandler] repeatVoiceMessageRequest];
                [[asyncUDPConnectionHandler sharedHandler]sendVoiceMessage:repeatMessageRequestJSON toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
            }
        }
        
    }
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.chatTableView reloadData];
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.frame.size.height)];
    
}

- (void)oneToOneChatDeclined:(NSNotification *)notification {

    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    User *refuserUser = [[User alloc] initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                          deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                              name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                         andActive:NO];
    
    
    
    if([refuserUser.deviceID isEqualToString:self.oponentUser.deviceID] && [refuserUser.deviceIP isEqualToString:self.oponentUser.deviceIP]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Declined"
                                                        message: [NSString stringWithFormat:@"%@ has declined your personal chat request.", self.oponentUser.deviceName]
                                                       delegate: self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        alert.tag = 99;
        [alert show];
    }
}

- (void)oneToOneChatAcceptFromStartPage:(NSNotification *)notification {
 
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    User *accepterUser = [[User alloc] initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                        deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                            name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                       andActive:YES];
    
    
    if([accepterUser.deviceID isEqualToString:self.oponentUser.deviceID] && [accepterUser.deviceIP isEqualToString:self.oponentUser.deviceIP]){
        
        [[ChannelHandler sharedHandler] setActive:YES toUser:accepterUser];
        self.oponentUser.isActive = YES;
        //reload the table
        [self.channelMemberTableView reloadData];
    }
    
    
}

- (void)fileMessageReceived:(NSNotification *)notification {
    
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];

//    NSDictionary * postDictionary = @{
//                                      JSON_KEY_TYPE : @(TYPE_FILE_MESSAGE),
//                                      JSON_KEY_CHANNEL: @(channelID),
//                                      JSON_KEY_DEVICE_NAME : [UIDevice currentDevice].name,
//                                      JSON_KEY_FILE_TYPE: @(type),
//                                      JSON_KEY_FILE_NAME: fileName,
//                                      JSON_KEY_FILE_MESSAGE: [encodedStringChunksArray objectAtIndex:i],
//                                      JSON_KEY_FILE_CHUNK_COUNT: @(chunkCount),
//                                      JSON_KEY_FILE_CURRENT_CHUNK: @(i+1)
//                                      };
    
    
    int fileType = [[jsonDict objectForKey:JSON_KEY_FILE_TYPE] intValue];
    
    switch (fileType) {
        case kFileTypeAudio:
            
            [self voiceFileReceived:jsonDict];
            break;
        case kFileTypeVideo:
            
            
            break;
        case kFileTypePhoto:
            
            
            break;
        case kFileTypeOthers:
            
            
            break;
            
        default:
            break;
    }
}

- (void)fileRepeatRequestReceived:(NSNotification *)notification {
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    int fileType = [[jsonDict objectForKey:JSON_KEY_FILE_TYPE] intValue];
    NSString *fileName = [jsonDict objectForKey:JSON_KEY_FILE_NAME];
    NSString *senderIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];

    
    int channelID = self.isPersonalChannel ? 0 :self.currentActiveChannel.channelID;
    NSArray *chunkStringArray = [[MessageHandler sharedHandler] jsonStringArrayWithFile:fileName OfType:fileType inChannel:channelID];
    
    
    if(chunkStringArray) {
        
        for (int j = 0; j<chunkStringArray.count; j++) {
            
            [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[chunkStringArray objectAtIndex:j] toIPAddress:senderIP];
        }
    }
}


#pragma mark Observer Helpers


-(void)voiceFileReceived:(NSDictionary*) jsonDict{
    
    int fileType = [[jsonDict objectForKey: JSON_KEY_FILE_TYPE] intValue];
    NSString * fileName = [jsonDict objectForKey: JSON_KEY_FILE_NAME];
    NSString *senderIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];
    
    int totalChunkCount = [[jsonDict objectForKey:JSON_KEY_FILE_CHUNK_COUNT] intValue];
    int currentChunk  = [[jsonDict objectForKey:JSON_KEY_FILE_CURRENT_CHUNK] intValue];
    NSString *base64EncodedVoiceString = [jsonDict objectForKey:JSON_KEY_FILE_MESSAGE];
    NSData *audioDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedVoiceString options:1];
    
    
    if (currentChunk == 1) {
        
        finalAudioData = nil;
        audioData = nil;
        chunkCounter = 1;
        audioData = [[NSMutableData alloc] initWithData:audioDataFromBase64String];
        
    }else {
        
        chunkCounter ++;
        [audioData appendData:audioDataFromBase64String];
        
        if (currentChunk == totalChunkCount) {
            
            
            if (chunkCounter == totalChunkCount) {
                
                //clear chunkCounter
                chunkCounter = 0;
        
                finalAudioData = [[NSData alloc] initWithData:audioData];
                
                [[FileHandler sharedHandler] writeData:finalAudioData toFileName:fileName ofType:kFileTypeAudio];
                [receivedAudioFileNames addObject:fileName];


                // voice message
                NSDictionary *messageDic = @{
                                             @"type": MesssageType_Voice_Other,
                                             @"sender": [jsonDict objectForKey:JSON_KEY_DEVICE_NAME],
                                             @"message": @"sent a voice message ▶️"
                                             };
                [self updateUIForChatMessage:messageDic];
                
            } else{
                
                //clear chunkCounter
                chunkCounter = 0;
                
                NSString *repeatMessageRequestJSON = [[MessageHandler sharedHandler] repeatRequestWithFile:fileName OfType:fileType];
                [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:repeatMessageRequestJSON toIPAddress:senderIP];
            }
        }
    }
}




#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 99) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}




#pragma mark Helper

-(void)addNewChannelToChannelListForJoinedChannelWithChannelData:(NSDictionary *)channelData{
    
    Channel *blankChannel = [[Channel alloc] init];
    [blankChannel addUserToChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];

    
    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] confirmJoiningForChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:[channelData objectForKey:JSON_KEY_DEVICE_NAME]];
    
    Channel *currentlyActiveChannel = [blankChannel geChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
    
    for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
        if (i!=0) {
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
        }
       
    }
    
//    [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
}

-(void)notifyMyPresenceInPublicChannelToNewlyJoinedIP:(NSDictionary *)channelData{
    
    Channel *blankChannel = [[Channel alloc] init];
    [blankChannel addUserToForeignChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
    
    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] confirmJoiningForChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:self.currentActiveChannel.channelMemberNamess[0]];
    
    [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
    
    
    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
//    Channel *currentlyactiveChannel = self.currentActiveChannel;
    
}



#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{


    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"MyAudioMemo.m4a"];
    NSData *recAudioData = [[FileHandler sharedHandler] dataFromFilePath:filePath];
    
    NSString * audioFileName = [FileHandler getFileNameOfType:kFileTypeAudio];

    
    [[FileHandler sharedHandler] writeData:recAudioData toFileName:audioFileName ofType:kFileTypeAudio];
    
    //Save
    [recordedAudioFileNames addObject:audioFileName];
    
    
    
    [self.recordPauseButton setBackgroundImage:[UIImage imageNamed:@"Record srt"] forState:UIControlStateNormal];
    [self.playButton setEnabled:YES];
    [self.sendButton setEnabled:YES];
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

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self stopImageEqualizer];
    [self.thePlayer stop];
    
//    if (receivedAudioStreamContainerArray.count > 0) {
//        [receivedAudioStreamContainerArray removeObjectAtIndex:0];
//        [self playAudioStream];
//    }
//    else{
//        _isPlayingStream = NO;
//    }
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



#pragma mark - UITableView

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[IncomingMessageCell class]]) {
        
        NSDictionary *messageDic = [chatMessageList objectAtIndex:indexPath.row];
        
        IncomingMessageCell *textCell = (IncomingMessageCell *)cell;
        
        if([messageDic[@"type"] isEqual: MesssageType_Text_Me]) {
            
            textCell.nameLabel.text = messageDic[@"sender"];
            textCell.chat_Text_Label.text = messageDic[@"message"];
            textCell.nameLabel.textAlignment = NSTextAlignmentRight;
            textCell.chat_Text_Label.textAlignment = NSTextAlignmentRight;
            
            
        }else if([messageDic[@"type"] isEqual: MesssageType_Text_Other]) {
            
            textCell.nameLabel.text = messageDic[@"sender"];
            textCell.chat_Text_Label.text = messageDic[@"message"];
            
            
            
        }else if([messageDic[@"type"] isEqual: MesssageType_Voice_Me]) {
            
            //Do Necessary Work
            if(![audioFileNamesDic objectForKey:@(indexPath.row)]){
                
                [audioFileNamesDic setObject:[recordedAudioFileNames lastObject] forKey:@(indexPath.row)];
            }
            
            textCell.nameLabel.text = messageDic[@"sender"];
            textCell.chat_Text_Label.text = messageDic[@"message"];
            textCell.nameLabel.textAlignment = NSTextAlignmentRight;
            textCell.chat_Text_Label.textAlignment = NSTextAlignmentRight;
            
        }else if([messageDic[@"type"] isEqual: MesssageType_Voice_Other]) {
            
            //Do Necessary Work
            if(![audioFileNamesDic objectForKey:@(indexPath.row)]){
                
                [audioFileNamesDic setObject:[receivedAudioFileNames lastObject] forKey:@(indexPath.row)];
            }
            
            textCell.nameLabel.text = messageDic[@"sender"];
            textCell.chat_Text_Label.text = messageDic[@"message"];
            
        }else if([messageDic[@"type"] isEqual: MesssageType_Left_Channel]) {
            
            textCell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",messageDic[@"sender"], messageDic[@"message"] ];
            textCell.chat_Text_Label.text = @"";
        }
        
        textCell.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        textCell.chat_Text_Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
}

- (IncomingMessageCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.chatTableView dequeueReusableCellWithIdentifier:incomingMessageCellIdentifier];
    }
    return _prototypeCell;
}


#pragma mark UITableViewDataSource

static NSString *incomingMessageCellIdentifier = @"incomingChatMessageCellID";
static NSString *chatmemberCellID = @"chatmemberCellID";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView.tag ==102) {
        return chatRoomMemberList.count;
        
    }else if (tableView.tag ==101) {
        return chatMessageList.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (tableView.tag == 102) {
        
        
        channelMemberActivityTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:chatmemberCellID forIndexPath:indexPath];
        cell2.userName.text = [chatRoomMemberList objectAtIndex:indexPath.row];
        
        if(self.isPersonalChannel){
            
            
            
            if(self.oponentUser.isActive){
                NSLog(@"active");
                cell2.presenceImage.image = [UIImage imageNamed:@"Membar active"];
            }else{
                NSLog(@"inactive");
                cell2.presenceImage.image = [UIImage imageNamed:@"Membar inactive"];
            }
        }
        
        return cell2;
        
        
    } else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:incomingMessageCellIdentifier forIndexPath:indexPath];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;

    }
    
}

    
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 102) {
        return 26;
    }
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    self.prototypeCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.chatTableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));

    [self.prototypeCell layoutIfNeeded];

    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * audioFileName = [audioFileNamesDic objectForKey:@(indexPath.row)];
    [self playAudioFileName:audioFileName];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark Helpers

- (void)playAudioFileName:(NSString *)audioFileName{
    
    if(audioFileName){
        
        if (!recorder.recording){
            
            NSString *audioFilePath = [[FileHandler sharedHandler] pathToFileWithFileName:audioFileName OfType:kFileTypeAudio];
            NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
            
            NSError *error = nil;
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
            if (!fileExists) {
                NSLog(@"File Doesn't Exist!");
                
                
                return;
            }
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            
            self.thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
            if (error) {
                NSLog(@"Audio can't play. Error %@", [error localizedDescription]);
            } else {
                [self.thePlayer setDelegate:self];
                [self.thePlayer play];
            }
        }
    }
    return;
}


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    CGRect frame = self.chatTableView.frame;
//    frame.size = self.chatTableView.contentSize;
//    
//    if (frame.size.height > self.chatTableContainerView.frame.size.height) {
//        frame.size.height = self.chatTableContainerView.frame.size.height;
//     }
//    self.chatTableView.frame = frame;
}

-(void)ScreenTapped {
    
    [self.view endEditing:YES];
    self.bottomSpaceForSendContainer.constant = 0;
    [self.view layoutIfNeeded];
}

-(void)keyboardWasShown:(NSNotification*)notification {
    
    
//    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
//    self.bottomSpaceForSendContainer.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);;
//    [self.view layoutIfNeeded];
    
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    self.bottomSpaceForSendContainer.constant = height;
    [self.view layoutIfNeeded];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:@"voiceMessageSegue"]) {
//        RecordViewController *recordControl = segue.destinationViewController;
//        recordControl.activeChannelInfo = self.currentActiveChannel;
//    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

//-(void) updateViewConstraints {
//    
//    NSLog(@"fdff");
//}


@end
