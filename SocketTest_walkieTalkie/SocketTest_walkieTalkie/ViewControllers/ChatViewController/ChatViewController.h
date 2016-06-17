//
//  ChatViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ChatViewController : UIViewController <UITextFieldDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate>


@property BOOL isPersonalChannel;
@property (strong, nonatomic) User *oponentUser;

@property (strong, nonatomic) Channel *currentActiveChannel;
@property (nonatomic, strong) AVAudioPlayer *thePlayer;

//@property (weak, nonatomic) IBOutlet UILabel *channelMemberListLabel;
//@property (weak, nonatomic) IBOutlet UILabel *chatViewLabel;

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceForSendContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintchatMemberTable;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraintOfChatTable;





#pragma mark - Voice View
@property (weak, nonatomic) IBOutlet UIView *voiceMailView;

@property (weak, nonatomic) IBOutlet UIView *popupBoxView;

@property (weak, nonatomic) IBOutlet UIImageView *equalizerImage;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceStreamerButton;


#pragma mark Action
- (IBAction)closeTappedOnVoiceMailView:(id)sender;
- (IBAction)recordPauseTapped:(id)sender;
//- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)sendTapped:(id)sender;


//@property (weak, nonatomic) IBOutlet UIButton *stopButton;
//@property (weak, nonatomic) IBOutlet UIButton *audioReceivedButton;

@property (weak, nonatomic) IBOutlet UIView *memberTableContainerView;

@property (weak, nonatomic) IBOutlet UIView *chatTableContainerView;


@property (weak, nonatomic) IBOutlet UITableView *channelMemberTableView;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;






@end
