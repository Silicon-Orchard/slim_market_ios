//
//  VoiceView.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 7/1/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//


#import <UIKit/UIKit.h>

@class MessageData;

// TAG used in our custom table view cell to retreive this view
#define VOICE_VIEW_TAG (103)



@interface VoiceView : UIView

@property (nonatomic, retain) UIButton *playBtn;
@property (nonatomic, assign) MessageData *messageData;

// Class method for computing a view height based on a given message transcript
+ (CGFloat)viewHeightForTranscript:(MessageData *)messageData;

@end