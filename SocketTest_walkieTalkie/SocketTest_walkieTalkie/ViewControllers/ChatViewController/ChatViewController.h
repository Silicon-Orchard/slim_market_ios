//
//  ChatViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IPChangeNotifier.h"


@interface ChatViewController : UIViewController <UITextFieldDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, IPChangeNotifierDelegate>


@property BOOL isPrivateChannel;
@property (strong, nonatomic) User *oponentUser;

@property (strong, nonatomic) Channel *currentActiveChannel;
@property (nonatomic, strong) AVAudioPlayer *thePlayer;


@property (weak, nonatomic) IBOutlet UIButton *textSendBtn;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceForSendContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintchatMemberTable;


#pragma mark - Voice View
@property (weak, nonatomic) IBOutlet UIView *voiceMailView;

@property (weak, nonatomic) IBOutlet UIView *popupBoxView;

@property (weak, nonatomic) IBOutlet UIImageView *equalizerImage;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceStreamerButton;


@property (weak, nonatomic) IBOutlet UIButton *streamBtn;


#pragma mark - IBAction
#pragma mark Voice-Action
- (IBAction)tappedOnVoiceBtn:(id)sender;
- (IBAction)closeTappedOnVoiceMailView:(id)sender;
- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)sendTapped:(id)sender;

#pragma mark - File
@property (weak, nonatomic) IBOutlet UIButton *attachBtn;

@property (weak, nonatomic) IBOutlet UIView *popupFileView;

- (IBAction)tappedOnAttachBtn:(id)sender;
- (IBAction)tappedOnFileBtn:(id)sender;
- (IBAction)tappedOnPhotoBtn:(id)sender;

#pragma mark - Stream
- (IBAction)tappedOnStreamBtn:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *memberTableContainerView;

@property (weak, nonatomic) IBOutlet UIView *chatTableContainerView;


@property (weak, nonatomic) IBOutlet UITableView *channelMemberTableView;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;









@end
