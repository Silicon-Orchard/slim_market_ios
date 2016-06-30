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
#import <AssetsLibrary/AssetsLibrary.h>

#import "MessageView.h"
#import "ImageView.h"
#import "ProgressView.h"

#import "IPChangeNotifier.h"



#define VoiceMessageSign @"voice&^%"

#define MESSAGE_SENDER_ME           @(0)
#define MESSAGE_SENDER_OTHER        @(1)

#define MESSAGE_TYPE_TEXT           ((int) 0)
#define MESSAGE_TYPE_AUDIO          ((int) 1)
#define MESSAGE_TYPE_VIDEO          ((int) 2)
#define MESSAGE_TYPE_PHOTO          ((int) 3)
#define MESSAGE_TYPE_OTHERS         ((int) 4)

#define MESSAGE_TYPE_LEFT          ((int) 10)

typedef void(^myCompletion)(BOOL);


@interface ChatViewController (){
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSMutableArray *recordedAudioFileNames;
    
    NSMutableDictionary * audioFileNamesDic;
    NSMutableDictionary * receivedAudioDic;
    
    
    NSURL *receivedSoundURL;
    NSMutableData *audioData;
    NSData *finalAudioData;
    int chunkCounter;
    BOOL _isStreaming, _isPlayingStream;
    AudioRecorderTest *queueRecorder;
    NSMutableArray *receivedAudioStreamContainerArray;
    
    NSMutableArray *chatRoomMemberList;
    
    NSMutableArray * messageDataList;
    
    BOOL addingVoiceMessage;
    
    
    NSMutableData *receivedFileData;
    NSData *finalFileData;
}


@property (nonatomic, strong) IncomingMessageCell *prototypeCell;
@end

@implementation ChatViewController
//@synthesize playButton, recordPauseButton;


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    recordedAudioFileNames = [NSMutableArray new];
    
    addingVoiceMessage = NO;
    audioFileNamesDic = [NSMutableDictionary new];
    
    messageDataList = [[NSMutableArray alloc] init];
    chatRoomMemberList = [[NSMutableArray alloc] init];
    receivedAudioStreamContainerArray = [[NSMutableArray alloc] init];
    //[ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
    
    
    receivedFileData = [NSMutableData new];
    finalFileData = [NSData new];
    
    chunkCounter = 0;
    
    
    //Emergency UI Update
    [self updateChannelMemberTable];
    if(self.isPrivateChannel){
        
        [self updateUIForPrivateMessage];
    }
    //else{
        //[self updateUIForChatViewWithChannel:self.currentActiveChannel];
    //}
    
    [self initWithNotification];
    [self initWithConfig];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    aTap.cancelsTouchesInView = NO;
    aTap.delegate = self;
    [self.view addGestureRecognizer:aTap];
    
    [self.playButton setEnabled:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setNavigationItemTitle];
    
    self.sendButton.enabled = NO;
    //self.audioReceivedButton.hidden = YES;
    
    self.popupBoxView.layer.cornerRadius = 10;
    self.popupBoxView.layer.masksToBounds = YES;
    
    
    //self.navigationController.navigationBar.topItem.title = @"Back";


}

-(void)viewDidAppear:(BOOL)animated{
    
    if(!self.isPrivateChannel){
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.frame.size.height)];
        //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:chatMessageList.count-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    
    if(numberOfViewControllersOnStack > 1){
        
        UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack - 1];
        Class parentVCClass = [parentViewController class];
        NSString *className = NSStringFromClass(parentVCClass);
        
        
//        if([className isEqualToString:@"CreateChannelViewController"]){
//            
//            //self.title =
//            self.navigationController.navigationBar.topItem.title = @"Create Channel";
//            
//        }else if ([className isEqualToString:@"JoinChannelViewController"]){
//            
//            self.navigationController.navigationBar.topItem.title = @"Join Channel";
//            
//        }else if ([className isEqualToString:@"ContactListVC"]){
//            
//            self.navigationController.navigationBar.topItem.title = @"Contact List";
//        }
        
        NSLog(@"%@", className);
    }

    
    

    
    if (self.isPrivateChannel) {
        
        
    }
   
    if ([[self backViewController] isKindOfClass:[JoinChannelViewController class]]) {
        JoinChannelViewController *previousViewController = (JoinChannelViewController *)[self backViewController];
        previousViewController.isChatOpen = NO;
    }
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // Navigation button was pressed.
         
        [self sendChannelLeaveMessage];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[self.chatTableView removeObserver:self forKeyPath:@"contentSize"];
    [[FileHandler sharedHandler] deleteWalkieTalkieDirectory];
    
    
    if(self.isPrivateChannel){
        NSLog(@"removing Oponent User from accepted list");
        [[ChannelManager sharedInstance] removeOponetUserFromAcceptedList:self.oponentUser];
    }
    
}


#pragma mark - Helpers

-(void)initWithNotification {

    //UDP Response Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelRequestReceived:) name:JOINCHANNEL_REQUEST_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelConfirmation:) name:JOINCHANNEL_CONFIRM_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duplicateChannelReceived:) name:CHANNEL_DUPLICATE_NOTIFICATIONKEY object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageReceived:) name:CHATMESSAGE_RECEIVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelLeftMessageReceieved:) name:CHANNEL_LEFT_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceStreamReceivedInChat:) name:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceMessageReceived:) name:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForRepeatVoiceMessagereceived:) name:UDP_VOICE_MESSAGE_REPEAR_REQUEST_NOTIFICATIONKEY object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileMessageReceived:) name:FILE_RECEIEVED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileRepeatRequestReceived:) name:FILE_REPEAT_REQUEST_NOTIFICATIONKEY object:nil];


    
    if(self.isPrivateChannel){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatDeclined:) name:ONE_TO_ONE_CHAT_DECLINE_NOTIFICATIONKEY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatAcceptFromStartPage:) name:ONE_TO_ONE_CHAT_ACCEPT_FROM_STARTPAGE_NOTIFICATIONKEY object:nil];
        
    }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelUpdated:) name:@"currentChannelUpdated" object:nil];
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
}

-(void)setNavigationItemTitle{
    
    if(self.isPrivateChannel){
        
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

-(UIViewController *)backViewController
{
    NSArray * stack = self.navigationController.viewControllers;
    
    return stack.lastObject;
}

-(void)sendChannelLeaveMessage{
    
    int channelID = self.isPrivateChannel ? kChannelIDPersonal : self.currentActiveChannel.channelID;
    NSString *deviceName = [UserHandler sharedInstance].mySelf.deviceName;
    
    NSString *leaveMessageToSend = [[MessageHandler sharedHandler] leaveChatMessageWithChannelID:channelID  deviceName:deviceName];
    
    if(self.isPrivateChannel){
        
        [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:self.oponentUser.deviceIP];
        
    }else{
        
        NSArray *channelMembers = [self.currentActiveChannel getMembers];
        
        for (User *member in channelMembers) {
            
            [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:member.deviceIP];
        }
        
    }
    
}

#pragma mark - UIHelpers

-(void)updateChannelMemberTable{
    
    chatRoomMemberList = [[NSMutableArray alloc] init];
    

    
    User *mySelf = [UserHandler sharedInstance].mySelf;
//    if([ChannelManager sharedInstance].isHost){
//        
//        mySelf.deviceName = [NSString stringWithFormat:@"%@ Owner", mySelf.deviceName];
//    }
    [chatRoomMemberList addObject:mySelf];
    
    NSArray *members =  [self.currentActiveChannel getMembers];
    for(User * member in members){
        
        [chatRoomMemberList addObject:member];
    }
    
    [self.channelMemberTableView reloadData];
}

//-(void)updateUIForChatViewWithChannel:(Channel *)currentChatChannel{
//
//    chatRoomMemberList = [[NSMutableArray alloc] init];
//    for (int i = 0; i < currentChatChannel.channelMemberIPs.count; i++) {
//        if (i==0) {
//            if (currentChatChannel.channelID ==1 || currentChatChannel.channelID ==2) {
//
//                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
//            }
//            else{
//
//                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Owner", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
//            }
//        }
//        else{
//
//            [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ Joined", [currentChatChannel.channelMemberNamess objectAtIndex:i]]];
//        }
//
//    }
//    
//    [self.channelMemberTableView reloadData];
//}

-(void)updateUIForPrivateMessage{
    
    //[chatRoomMemberList addObject:self.oponentUser.deviceName];
    
    //self.topSpaceConstraintOfChatTable = 0;
    self.heightConstraintchatMemberTable.constant = 60.0f;
    [self.view layoutIfNeeded];
}

-(void)updateUIForChatMessage:(MessageData *)messagedData {
    
    [messageDataList addObject:messagedData];
    
    NSIndexPath * indexPathOfYourCell = [NSIndexPath indexPathForRow:([messageDataList count] - 1) inSection:0];
    
    [self.chatTableView beginUpdates];
    [self.chatTableView insertRowsAtIndexPaths:@[indexPathOfYourCell] withRowAnimation:UITableViewRowAnimationFade];
    [self.chatTableView endUpdates];
    
    // Scroll to the bottom so we focus on the latest message
    NSUInteger numberOfRows = [self.chatTableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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
    
    NSString * deviceName = [UserHandler sharedInstance].mySelf.deviceName;
    
    if(self.isPrivateChannel && !self.oponentUser.isActive){

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Rechable"
                                                        message: [NSString stringWithFormat:@"%@ is not reachable right now & won't be abble to receive message.", self.oponentUser.deviceName]
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        
        [alert show];
        return;
    }
    

    NSString *chatMessageToSend = [[MessageHandler sharedHandler] createChatMessageWithChannelID:self.currentActiveChannel.channelID deviceName:deviceName chatmessage:self.chatTextField.text];
    
    
    NSArray *channelMembers = [self.currentActiveChannel getMembers];
    
    for (User *member in channelMembers) {
        
        
        [[asyncUDPConnectionHandler sharedHandler] sendMessage:chatMessageToSend toIPAddress:member.deviceIP];
    }
    
    MessageData * messageData = [[MessageData alloc] initWithSender:@"Me"  type:MESSAGE_TYPE_TEXT message:self.chatTextField.text direction:MESSAGE_DIRECTION_SEND];
    [self updateUIForChatMessage:messageData];
    
    //self.chatTextField.text = @"";
}


- (IBAction)tappedOnVoiceBtn:(id)sender {
    
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

        NSString * fileName = [recordedAudioFileNames lastObject];
        NSString *audioFilePath = [[FileHandler sharedHandler] pathToFileWithFileName:fileName OfType:kFileTypeAudio];
        
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
    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
    
    self.sendButton.enabled = NO;
    NSString *audioFileName = [recordedAudioFileNames lastObject];
    
    [self sendFile:audioFileName ofType:kFileTypeAudio andCompletionBlock:^(BOOL finished) {
        
        if(finished){
            
            self.sendButton.enabled = YES;
        }
    }];

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

#pragma mark IBAction of AttachBtn

- (IBAction)tappedOnAttachBtn:(id)sender {
    
    self.popupFileView.hidden = !self.popupFileView.hidden;
    
}

- (IBAction)tappedOnFileBtn:(id)sender {
    
    
}

- (IBAction)tappedOnPhotoBtn:(id)sender {
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Options" message:@"Either capture an image from the camera or open from the Photo Library." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Camera button tapped.
        [self dismissViewControllerAnimated:NO completion:NULL];
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Photo Gallery button tapped.
        [self dismissViewControllerAnimated:NO completion:nil];

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark IBAction of StreamBtn

- (IBAction)tappedOnStreamBtn:(id)sender {
    
    
}




#pragma mark - Noticfication
#pragma mark Observer

-(void) chatMessageReceived:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    
    NSString *senderName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
    NSString *message = [jsonDict objectForKey:JSON_KEY_MESSAGE];
    
    MessageData *messageData = [[MessageData alloc] initWithSender:senderName type:MESSAGE_TYPE_TEXT message:message direction:MESSAGE_DIRECTION_RECEIVE];
    [self updateUIForChatMessage:messageData];
}


-(void) joinChannelRequestReceived:(NSNotification*)notification{
    
    
    if(self.isPrivateChannel) {
        
        
    }else{
        
        NSDictionary* userInfo = notification.userInfo;
        NSData* receivedData = (NSData*)userInfo[@"receievedData"];
        NSLog (@"Successfully received native Channel joined notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
        NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
        
        int requestChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
        
        if(self.currentActiveChannel.channelID == requestChannelID) {
            
            //sendJoiningChannelConfirmationMessage
            
            User *requestMember = [[User alloc] initWithIP:jsonDict[JSON_KEY_IP_ADDRESS] deviceID:jsonDict[JSON_KEY_DEVICE_ID] name:jsonDict[JSON_KEY_DEVICE_NAME] andActive:YES];
            [self.currentActiveChannel addMember:requestMember];
            [self.currentActiveChannel setActive:YES toUser:requestMember];
            
            NSString *myChannelName = [UserHandler sharedInstance].mySelf.deviceName;
            NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] joiningChannelConfirmationMessageOf:requestChannelID channelName:myChannelName];
            
            
            
            //Send
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
            
            
            
            //Update updateChannelMemberTable
            [self updateChannelMemberTable];
        }
    }
}


-(void) joinChannelConfirmation:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    int requestedChannelID = [jsonDict[@"channel_id"] intValue];


    if(jsonDict && requestedChannelID == self.currentActiveChannel.channelID){
        
        if(self.isPrivateChannel && requestedChannelID == kChannelIDPersonal) {
            
            
            
        }else{
            
//            NSString *name = jsonDict[JSON_KEY_DEVICE_NAME];
//            NSString *dID = jsonDict[JSON_KEY_DEVICE_ID];
//            NSString *ip = jsonDict[JSON_KEY_IP_ADDRESS];
            
            User * confirmedMember = [[User alloc] initWithDictionary:jsonDict];
            [self.currentActiveChannel addMember:confirmedMember];
            [self.currentActiveChannel setActive:YES toUser:confirmedMember];
            
            
//            NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
//            NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
//            NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];
//            
//            for (int i = 0; i < channelmembers.count; i++) {
//                NSDictionary *channelMember = [channelmembers objectAtIndex:i];
//                [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
//                [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
//            }
            
            [self updateChannelMemberTable];
        }
    }
}


-(void) duplicateChannelReceived:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    int duplicateChannelID = [jsonDict[@"channel_id"] intValue];
    
    
    if(duplicateChannelID == self.currentActiveChannel.channelID){
        
        //duplicate channel, so leave
        
        //NSString *message;
        User *currentChannelHostUser = self.currentActiveChannel.hostUser;
        User *mySelfUser = [UserHandler sharedInstance].mySelf;
        
        if([currentChannelHostUser.deviceID isEqualToString:mySelfUser.deviceID] && [currentChannelHostUser.deviceIP isEqualToString:mySelfUser.deviceIP]){
            
            //update channel
            NSDictionary *hostDic = jsonDict[JSON_KEY_HOST];
            User *hostUser = [[User alloc] initWithDictionary:hostDic andActive:YES];
            Channel *channel = [[Channel alloc] initChannelWithID:duplicateChannelID andHost:hostUser];
            [[ChannelManager sharedInstance] updateChannel:channel ofChannelID:duplicateChannelID];
            
            
            //show alert and then quit thi VC
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Duplicate Channel!!!"
                                                            message: @"You have created a channel with duplicate channel number. Please create channel with different channel number."
                                                           delegate: self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.tag = 99;
            [alert show];
        }
        
    }
}


-(void) ChannelLeftMessageReceieved:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];

    User * leftMember = [[User alloc] initWithDictionary:jsonDict];
    [self.currentActiveChannel setActive:NO toUser:leftMember];
    
    if([self.currentActiveChannel isPrivateChannelWith:leftMember]){
        [[ChannelManager sharedInstance] setActive:NO toUser:leftMember];
    }
    
    

    
    if( [self.currentActiveChannel isPersonalChannel] ){
        
        User *hostUser = [ChannelManager sharedInstance].hostUser;
        if( (hostUser.deviceID == leftMember.deviceID) && (hostUser.deviceIP == leftMember.deviceIP) ){
            // channel owner left the channel, Show Alert & leave the channel
            
            //remove channel
            [[ChannelManager sharedInstance] removeChannel:self.currentActiveChannel.channelID];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Channel Owner Left!"
                                                            message: [NSString stringWithFormat:@"Channel owner,  %@ has left his private channel. You are suppposed to leave this channel by confirming OK.", leftMember.deviceName]
                                                           delegate: self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            alert.tag = 99;
            [alert show];
        }
    }
    
    
    
    //Update the Chat member Table
    [self updateChannelMemberTable];
    
    
//    if(self.isPrivateChannel){
//        
//        
//        NSLog(@"This user has left PersonalChannel!");
//        
////        User * leftUser = [[User alloc] initWithDictionary:jsonDict];
////        [[ChannelHandler sharedHandler] setActive:NO toUser:leftUser];
//        
//        self.oponentUser.isActive = NO;
//        [self.channelMemberTableView reloadData];
//        
//    }else {
//        
//        
//
//        
//        
//        
//        Channel *currentlyActiveChannel;
//        if ([ChannelHandler sharedHandler].isHost) {
//            currentlyActiveChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
//        }
//        else{
//            currentlyActiveChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
//        }
//        NSString *leftMemberIP;
//        NSString *leftMemberName;
//        
//        if ([currentlyActiveChannel.foreignChannelHostIP isEqualToString:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]]) {
//            [self.currentActiveChannel removeChannelWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else{
//            if (currentlyActiveChannel.channelID == [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]) {
//                for (int i = 0; i < currentlyActiveChannel.channelMemberIPs.count; i++) {
//                    NSString *memberIP = [currentlyActiveChannel.channelMemberIPs objectAtIndex:i];
//                    if ([memberIP isEqualToString:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]]) {
//                        leftMemberIP = [[currentlyActiveChannel.channelMemberIPs objectAtIndex:i] copy];
//                        leftMemberName = [[currentlyActiveChannel.channelMemberNamess objectAtIndex:i] copy];
//                        
//                        [currentlyActiveChannel.channelMemberIPs removeObjectAtIndex:i];
//                        [currentlyActiveChannel.channelMemberNamess removeObjectAtIndex:i];
//                    }
//                    [self.currentActiveChannel replaceForeignChannelOfID:[ChannelHandler sharedHandler].currentlyActiveChannelID withChannel:currentlyActiveChannel];
//                    [self.currentActiveChannel replaceChannelOfID:[ChannelHandler sharedHandler].currentlyActiveChannelID withChannel:currentlyActiveChannel];
//                    self.currentActiveChannel = currentlyActiveChannel;
//                }
//                
//                [self updateUIForChatViewWithChannel:currentlyActiveChannel];
//                
//                
//
//                
//                
//                [chatRoomMemberList addObject:[NSString stringWithFormat:@"%@ has left!",leftMemberName]];
//                [self.channelMemberTableView reloadData];
//            }
//        }
//    }
    
    
    
}

//-(void) channelUpdated:(NSNotification*)notification{
//    Channel *newChannel;
//    if ([ChannelHandler sharedHandler].isHost) {
//        newChannel = [self.currentActiveChannel geChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
//    }
//    else{
//        newChannel = [self.currentActiveChannel getForeignChannel:[ChannelHandler sharedHandler].currentlyActiveChannelID];
//
//    }
//    
//    
//    self.currentActiveChannel = newChannel;
//    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
//    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
//}



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
        
        [[ChannelManager sharedInstance] setActive:YES toUser:accepterUser];
        self.oponentUser.isActive = YES;
        [self.currentActiveChannel addMember:accepterUser];
        [self.currentActiveChannel setActive:YES toUser:accepterUser];
        
        //reload the table
        [self updateChannelMemberTable];
    }
    
    
}

#pragma mark File Message Received

- (void)fileMessageReceived:(NSNotification *)notification {
    
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    int fileType = [[jsonDict objectForKey:JSON_KEY_FILE_TYPE] intValue];
    
    switch (fileType) {
        case kFileTypeAudio:
            
            //[self voiceFileReceived:jsonDict];
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
    
    
    int totalChunkCount = [[jsonDict objectForKey:JSON_KEY_FILE_CHUNK_COUNT] intValue];
    int currentChunk  = [[jsonDict objectForKey:JSON_KEY_FILE_CURRENT_CHUNK] intValue];
    NSString *base64EncodedString = [jsonDict objectForKey:JSON_KEY_FILE_MESSAGE];
    NSData *fileDataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:1];
    
    
    if (currentChunk == 1) {
        
        finalFileData = nil;
        receivedFileData = nil;
        chunkCounter = 1;
        printf("\nchunkCounter: %d\n", chunkCounter);
        
        receivedFileData = [[NSMutableData alloc] initWithData:fileDataFromBase64String];
        
    }else {
        
        chunkCounter ++;
        printf("\nchunkCounter: %d\n", chunkCounter);
        
        [receivedFileData appendData:fileDataFromBase64String];
        
        NSString * fileName = [jsonDict objectForKey: JSON_KEY_FILE_NAME];
        NSString *senderIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];

        
        if (currentChunk == totalChunkCount) {
            
            printf("\nFinal chunkCounter: %d\n", chunkCounter);
            
            if (chunkCounter == totalChunkCount) {
                
                //clear chunkCounter
                chunkCounter = 0;
                
                finalFileData = [[NSData alloc] initWithData:receivedFileData];
                
                [[FileHandler sharedHandler] writeData:finalFileData toFileName:fileName ofType:fileType];
                
                
                
                NSData *imageData = [NSData dataWithContentsOfFile:[[FileHandler sharedHandler] pathToFileWithFileName:fileName OfType:fileType]];
                NSUInteger byteCount = [imageData length];
                printf("\nReceving number of bytes: %lu\n", (unsigned long)byteCount);
                
                
                NSString *senderName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
                MessageData * messageData = [[MessageData alloc] initWithSender:senderName type:fileType message:fileName direction:MESSAGE_DIRECTION_RECEIVE];
                [self updateUIForChatMessage:messageData];
                
            } else{
                
                //clear chunkCounter
                chunkCounter = 0;
                
                NSString *repeatMessageRequestJSON = [[MessageHandler sharedHandler] repeatRequestWithFile:fileName OfType:fileType];
                [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:repeatMessageRequestJSON toIPAddress:senderIP];
            }
        }
    }
    

    
}

- (void)fileRepeatRequestReceived:(NSNotification *)notification {
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    int fileType = [[jsonDict objectForKey:JSON_KEY_FILE_TYPE] intValue];
    NSString *fileName = [jsonDict objectForKey:JSON_KEY_FILE_NAME];
    NSString *senderIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];

    
    int channelID = self.isPrivateChannel ? 0 :self.currentActiveChannel.channelID;
    NSArray *chunkStringArray = [[MessageHandler sharedHandler] jsonStringArrayWithFile:fileName OfType:fileType inChannel:channelID];
    
    
    if(chunkStringArray) {
        
        for (int j = 0; j<chunkStringArray.count; j++) {
            
            [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[chunkStringArray objectAtIndex:j] toIPAddress:senderIP];
        }
    }
}


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 99) {
        // Decline alert, Private Channel Owner left,
        [self.navigationController popViewControllerAnimated:YES];
    }
}




#pragma mark Helper

//-(void)addNewChannelToChannelListForJoinedChannelWithChannelData:(NSDictionary *)channelData{
//    
//    Channel *blankChannel = [[Channel alloc] init];
//    [blankChannel addUserToChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
//
//    
//    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] joiningChannelConfirmationMessageOf:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:[channelData objectForKey:JSON_KEY_DEVICE_NAME]];
//    
//    Channel *currentlyActiveChannel = [blankChannel geChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
//    
//    for (int i= 0; i<currentlyActiveChannel.channelMemberIPs.count; i++) {
//        if (i!=0) {
//            [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[currentlyActiveChannel.channelMemberIPs objectAtIndex:i]];
//        }
//       
//    }
//    
////    [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
//    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
//    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
//    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
//}
//
//-(void)notifyMyPresenceInPublicChannelToNewlyJoinedIP:(NSDictionary *)channelData{
//    
//    Channel *blankChannel = [[Channel alloc] init];
//    [blankChannel addUserToForeignChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
//    
//    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] joiningChannelConfirmationMessageOf:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:self.currentActiveChannel.channelMemberNamess[0]];
//    
//    [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];
//    
//    
//    self.currentActiveChannel = [blankChannel getForeignChannel:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue]];
//    [ChannelHandler sharedHandler].currentlyActiveChannel = self.currentActiveChannel;
//    [self updateUIForChatViewWithChannel:self.currentActiveChannel];
////    Channel *currentlyactiveChannel = self.currentActiveChannel;
//    
//}



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
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self stopImageEqualizer];
    [self.thePlayer stop];
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
        
//        MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];
//        
//        IncomingMessageCell *textCell = (IncomingMessageCell *)cell;
//        
//        
//        if([messageDic[@"sender"] isEqual: MESSAGE_SENDER_ME]){
//            
//            textCell.nameLabel.textAlignment = NSTextAlignmentRight;
//            textCell.chat_Text_Label.textAlignment = NSTextAlignmentRight;
//        }
//        
//        
//        
//        if([messageDic[@"type"] isEqual: MESSAGE_TYPE_TEXT]) {
//            
//            textCell.nameLabel.text = messageDic[@"sender_name"];
//            textCell.chat_Text_Label.text = messageDic[@"message"];
//            textCell.imageView.hidden = YES;
//
//            
//        }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_AUDIO]) {
//            
//            //Do Necessary Work
////            if(![audioFileNamesDic objectForKey:@(indexPath.row)]){
////                
////                [audioFileNamesDic setObject:[recordedAudioFileNames lastObject] forKey:@(indexPath.row)];
////            }
//            
//            textCell.nameLabel.text = messageDic[@"sender_name"];
//            textCell.chat_Text_Label.text = @"sent a voice message ▶️";
//            textCell.imageView.hidden = YES;
//
//        }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_VIDEO]) {
//            
//            
//            
//        }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_PHOTO]) {
//            textCell.chat_Text_Label.hidden = YES;
//            textCell.imageView.hidden = NO;
//            
//            //NSString *fileName = ;
//            
//            NSString *imageFilePath = [[FileHandler sharedHandler] pathToFileWithFileName:messageDic[@"message"] OfType:kFileTypePhoto];
//            UIImage * image = [UIImage imageWithContentsOfFile:imageFilePath];
//            
//            textCell.imageView.image =image;
//            
//            
//            
//            
//        }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_OTHERS]) {
//            textCell.imageView.hidden = YES;
//
//        
//        }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_LEFT]) {
//            
//            textCell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",messageDic[@"sender"], messageDic[@"message"] ];
//            textCell.chat_Text_Label.text = @"";
//        }
//        
//        textCell.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
//        textCell.chat_Text_Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    }
        
}

//- (IncomingMessageCell *)prototypeCell
//{
//    if (!_prototypeCell)
//    {
//        _prototypeCell = [self.chatTableView dequeueReusableCellWithIdentifier:incomingMessageCellIdentifier];
//    }
//    return _prototypeCell;
//}


#pragma mark UITableViewDataSource

static NSString *incomingMessageCellIdentifier = @"incomingChatMessageCellID";
static NSString *chatmemberCellID = @"chatmemberCellID";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView.tag ==102) {
        NSInteger count = chatRoomMemberList.count;
        return count;
        
    }else if (tableView.tag ==101) {
        return messageDataList.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (tableView.tag == 102) {
        
        
        channelMemberActivityTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:chatmemberCellID forIndexPath:indexPath];
        
        User *member = [chatRoomMemberList objectAtIndex:indexPath.row];
        
        
        if(member){
            
            cell2.userName.text = member.deviceName;
            
            if(member.isActive){
                NSLog(@"active");
                cell2.presenceImage.image = [UIImage imageNamed:@"Membar active"];
            }else{
                NSLog(@"inactive");
                cell2.presenceImage.image = [UIImage imageNamed:@"Membar inactive"];
            }
        }
        
//        if(self.isPrivateChannel){
//
//            
//            if(self.oponentUser.isActive){
//                NSLog(@"active");
//                cell2.presenceImage.image = [UIImage imageNamed:@"Membar active"];
//            }else{
//                NSLog(@"inactive");
//                cell2.presenceImage.image = [UIImage imageNamed:@"Membar inactive"];
//            }
//        }
        
        return cell2;
        
        
    } else{
        
        // Get the transcript for this row
        MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];
        

        UITableViewCell *cell;
        if (messageData.type == kFileTypePhoto) {

            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCellID" forIndexPath:indexPath];
            ImageView *imageView = (ImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
            imageView.messageData = messageData;
        }
        else if (messageData.progress != nil) {

            cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCellID" forIndexPath:indexPath];
            ProgressView *progressView = (ProgressView *)[cell viewWithTag:PROGRESS_VIEW_TAG];
            progressView.messageData = messageData;
        }
        else {

            cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCellID" forIndexPath:indexPath];
            MessageView *messageView = (MessageView *)[cell viewWithTag:MESSAGE_VIEW_TAG];
            messageView.messageData = messageData;
        }
        return cell;
        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:incomingMessageCellIdentifier forIndexPath:indexPath];
//        [self configureCell:cell forRowAtIndexPath:indexPath];
//        return cell;

    }
    
}

    
#pragma mark UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 102) {
        
        return 26;
    } else {
        
        // Dynamically compute the label size based on cell type (image, image progress, or text message)
        MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];
        if (messageData.type == kFileTypePhoto) {
            return [ImageView viewHeightForTranscript:messageData];
        }
        else if (messageData.progress != nil) {
            return [ProgressView viewHeightForTranscript:messageData];
        }
        else {
            return [MessageView viewHeightForTranscript:messageData];
        }
    }
    
//    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
//    self.prototypeCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.chatTableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
//
//    [self.prototypeCell layoutIfNeeded];
//
//    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height+1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSDictionary * messageDic = messageDataList[indexPath.row];
    
//    if([messageDic[@"type"] isEqual: MESSAGE_TYPE_TEXT] || [messageDic[@"type"] isEqual: MESSAGE_TYPE_LEFT]) {
//        
//
//        return nil;
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_AUDIO]) {
//        
//        
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_VIDEO]) {
//        
//        
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_PHOTO]) {
//        
//        
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_OTHERS]) {
//        
//        
//        
//    }
    
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSString * audioFileName = [audioFileNamesDic objectForKey:@(indexPath.row)];
    
    //MessageData * messageData = messageDataList[indexPath.row];
    
//    if([messageDic[@"type"] isEqual: MESSAGE_TYPE_TEXT] || [messageDic[@"type"] isEqual: MESSAGE_TYPE_LEFT]) {
//        
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        return;
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_AUDIO]) {
//        
//        NSString *audioFileName = messageDic[@"message"];
//        [self playAudioFileName:audioFileName];
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_VIDEO]) {
//        
//        
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_PHOTO]) {
//        
//        
//        
//    }else if([messageDic[@"type"] isEqual: MESSAGE_TYPE_OTHERS]) {
//        
//        
//        
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    //    }
    //    self.chatTableView.frame = frame;
}

-(void)ScreenTapped {
    
    [self.view endEditing:YES];
    self.bottomSpaceForSendContainer.constant = 0;
    [self.view layoutIfNeeded];
    
    if(!self.popupFileView.hidden){
        self.popupFileView.hidden = YES;
    }
}

-(void)keyboardWasShown:(NSNotification*)notification {

    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    self.bottomSpaceForSendContainer.constant = height;
    [self.view layoutIfNeeded];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if (([touch.view isDescendantOfView:self.attachBtn])) {//change it to your condition
        return NO;
    }
    
    if (([touch.view isDescendantOfView:self.textSendBtn])) {//change it to your condition
        return NO;
    }
    return YES;
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //Save the image
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [FileHandler getFileNameOfType:kFileTypePhoto];
    
    NSUInteger byteCount = [imageData length];
    
//    NSDictionary *messageDic = @{
//                                 @"sender": MESSAGE_SENDER_ME,
//                                 @"sender_name": @"Me",
//                                 @"type": MESSAGE_TYPE_TEXT,
//                                 @"message":
//                                 };
//    [self updateUIForChatMessage:messageDic];

    NSString *message = [NSString stringWithFormat:@"Sending number of bytes: %lul", (unsigned long)byteCount];
    MessageData * messageData = [[MessageData alloc] initWithSender:@"Me"  type:MESSAGE_TYPE_TEXT message:message direction:MESSAGE_DIRECTION_SEND];
    [self updateUIForChatMessage:messageData];
    
    
    [[FileHandler sharedHandler] writeData:imageData toFileName:fileName ofType:kFileTypePhoto];
    
    [self sendFile:fileName ofType:kFileTypePhoto andCompletionBlock:^(BOOL finished) {
        
        if(finished){
            
            
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)sendFile:(NSString *) fileName ofType:(int) fileType andCompletionBlock:(myCompletion) completionBlock {
    
    //self.sendButton.enabled = NO;
    
    
    int channelID = self.isPrivateChannel ? 0 :self.currentActiveChannel.channelID;
    NSArray *chunkStringArray = [[MessageHandler sharedHandler] jsonStringArrayWithFile:fileName OfType:fileType inChannel:channelID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.isPrivateChannel) {
            
            for (int j = 0; j<chunkStringArray.count; j++) {
                NSLog(@"message to send %@", [chunkStringArray objectAtIndex:j]);
                if (j%5 == 0) {
                    [NSThread sleepForTimeInterval:0.09];
                }
                [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[chunkStringArray objectAtIndex:j] toIPAddress:self.oponentUser.deviceIP];
            }
            
        }else {
            
            NSArray *channelMembers = [self.currentActiveChannel getMembers];
            
            for (User *member in channelMembers) {
                
                
                for (int j = 0; j<chunkStringArray.count; j++) {
                    NSLog(@"message to send %@", [chunkStringArray objectAtIndex:j]);
                    if (j%5 == 0) {
                        [NSThread sleepForTimeInterval:0.09];
                    }
                    
                    [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[chunkStringArray objectAtIndex:j] toIPAddress:member.deviceIP];
                }
            }
            
//            for (int i= 0; i<self.currentActiveChannel.channelMemberIPs.count; i++) {
//                if (![[self.currentActiveChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                    for (int j = 0; j<chunkStringArray.count; j++) {
//                        NSLog(@"message to send %@", [chunkStringArray objectAtIndex:j]);
//                        if (j%5 == 0) {
//                            [NSThread sleepForTimeInterval:0.09];
//                        }
//                        //                    [NSThread sleepForTimeInterval:0.09];
//                        [[asyncUDPConnectionHandler sharedHandler] sendVoiceMessage:[chunkStringArray objectAtIndex:j] toIPAddress:[self.currentActiveChannel.channelMemberIPs objectAtIndex:i]];
//                    }
//                }
//                
//            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                            message: [NSString stringWithFormat:@"Sent packet count %lu", (unsigned long)chunkStringArray.count] //@"Voice Message Sent to Channel Members!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            
            [alert show];
            
            completionBlock(YES);
            
            MessageData * messageData = [[MessageData alloc] initWithSender:@"Me" type:fileType message:fileName direction:MESSAGE_DIRECTION_SEND];
            [self updateUIForChatMessage:messageData];

        });
    });
    
}

#pragma mark - IPChangeNotifier
-(void) IPChangeDetected:(NSString*)newIP previousIP:(NSString*)oldIP {
    // Do what you need
}


@end
