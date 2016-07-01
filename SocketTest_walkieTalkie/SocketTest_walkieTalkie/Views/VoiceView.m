//
//  VoiceView.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 7/1/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "VoiceView.h"
#import "MessageData.h"

// Constants for view sizing and alignment
#define MESSAGE_FONT_SIZE       (17.0)
#define NAME_FONT_SIZE          (10.0)
#define BUFFER_WHITE_SPACE      (14.0)
#define DETAIL_TEXT_LABEL_WIDTH (220.0)
#define NAME_OFFSET_ADJUST      (4.0)

#define BALLOON_INSET_TOP    (46 / 2)
#define BALLOON_INSET_LEFT   (36 / 2)
#define BALLOON_INSET_BOTTOM (30 / 2)
#define BALLOON_INSET_RIGHT  (36 / 2)

#define BALLOON_INSET_WIDTH (BALLOON_INSET_LEFT + BALLOON_INSET_RIGHT)
#define BALLOON_INSET_HEIGHT (BALLOON_INSET_TOP + BALLOON_INSET_BOTTOM)

#define BALLOON_MIDDLE_WIDTH (30 / 2)
#define BALLOON_MIDDLE_HEIGHT (6 / 2)

#define BALLOON_MIN_HEIGHT (BALLOON_INSET_HEIGHT + BALLOON_MIDDLE_HEIGHT)

#define BALLOON_HEIGHT_PADDING (20)
#define BALLOON_WIDTH_PADDING (30)

#define BUTTON_CONSTANT (25)
#define BUTTON_WIDTH_PADDING (10)

@interface VoiceView ()

// Background image
@property (nonatomic, retain) UIImageView *balloonView;
// Message text string


@property (nonatomic, retain) UILabel *messageLabel;


// Name text (for received messages)

@property (nonatomic, retain) UILabel *nameLabel;


// Cache the background images and stretchable insets
@property (retain, nonatomic) UIImage *balloonImageLeft;
@property (retain, nonatomic) UIImage *balloonImageRight;
@property (assign, nonatomic) UIEdgeInsets balloonInsetsLeft;
@property (assign, nonatomic) UIEdgeInsets balloonInsetsRight;

@end



@implementation VoiceView

@synthesize playBtn;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Initialization the views
        _balloonView = [UIImageView new];
        _messageLabel = [UILabel new];
        _messageLabel.numberOfLines = 0;
        
        
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn addTarget:self action:@selector(tappedOnPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *btnImage = [UIImage imageNamed:@"Play icon"];
        [playBtn setImage:btnImage forState:UIControlStateNormal];
        //[button setTitle:@"" forState:UIControlStateNormal];
        //button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
        
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:NAME_FONT_SIZE];
        //_nameLabel.textColor = [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1];
        _nameLabel.textColor = [UIColor whiteColor];
        
        self.balloonImageLeft = [UIImage imageNamed:@"bubble-left.png"];
        self.balloonImageRight = [UIImage imageNamed:@"bubble-right.png"];
        
        _balloonInsetsLeft = UIEdgeInsetsMake(BALLOON_INSET_TOP, BALLOON_INSET_LEFT, BALLOON_INSET_BOTTOM, BALLOON_INSET_RIGHT);
        _balloonInsetsRight = UIEdgeInsetsMake(BALLOON_INSET_TOP, BALLOON_INSET_LEFT, BALLOON_INSET_BOTTOM, BALLOON_INSET_RIGHT);
        
        // Add to parent view
        [self addSubview:_balloonView];
        [self addSubview:_messageLabel];
        [self addSubview:_nameLabel];
        [self addSubview:playBtn];
    }
    return self;
}


-(void)tappedOnPlayBtn:(UIButton*)sender{
    
    
    
}



// Method for setting the transcript object which is used to build this view instance.
- (void)setMessageData:(MessageData *)messageData
{
    // Set the message text
    NSString *messageText = @"Voice Mail received";
    _messageLabel.text = messageText;
    //_messageLabel.text =
    
    // Compute message size and frames
    CGSize labelSize = [VoiceView labelSizeForString:messageText fontSize:MESSAGE_FONT_SIZE];
    CGSize balloonSize = [VoiceView balloonSizeForLabelSize:labelSize];
    balloonSize.width = balloonSize.width + BUTTON_CONSTANT + BUTTON_WIDTH_PADDING;
    
    
    NSString *nameText = messageData.senderName;
    CGSize nameSize = [VoiceView labelSizeForString:nameText fontSize:NAME_FONT_SIZE];
    
    // Comput the X,Y origin offsets
    CGFloat xOffsetLabel;
    CGFloat xOffsetBalloon;
    CGFloat yOffset;
    
    if (MESSAGE_DIRECTION_SEND == messageData.direction) {
        // Sent messages appear or right of view
        xOffsetLabel = self.superview.bounds.size.width - labelSize.width - (BALLOON_WIDTH_PADDING / 2) - 3 - BUTTON_CONSTANT - BUTTON_WIDTH_PADDING;
        xOffsetBalloon = self.superview.bounds.size.width - balloonSize.width;
        yOffset = BUFFER_WHITE_SPACE / 2;
        _nameLabel.text = @"";
        // Set text color
        _messageLabel.textColor = [UIColor whiteColor];
        // Set resizeable image
        _balloonView.image = [self.balloonImageRight resizableImageWithCapInsets:_balloonInsetsRight];
        
    } else {
        // Received messages appear on left of view with additional display name label
        xOffsetBalloon = 0;
        xOffsetLabel = (BALLOON_WIDTH_PADDING / 2) + 3 + BUTTON_CONSTANT + BUTTON_WIDTH_PADDING;;
        yOffset = (BUFFER_WHITE_SPACE / 2) + nameSize.height - NAME_OFFSET_ADJUST;
        if (MESSAGE_DIRECTION_LOCAL == messageData.direction) {
            _nameLabel.text = @"Session Admin";
        }
        else {
            _nameLabel.text = nameText;
        }
        // Set text color
        _messageLabel.textColor = [UIColor whiteColor];
        // Set resizeable image
        _balloonView.image = [self.balloonImageLeft resizableImageWithCapInsets:_balloonInsetsLeft];
    }
    
    // Set the dynamic frames
    _balloonView.frame = CGRectMake(xOffsetBalloon, yOffset, balloonSize.width, balloonSize.height);
    
    playBtn.frame = CGRectMake(xOffsetLabel, yOffset + 12, BUTTON_CONSTANT, BUTTON_CONSTANT );
    _messageLabel.frame = CGRectMake((xOffsetLabel + BUTTON_CONSTANT + BUTTON_WIDTH_PADDING), yOffset + 12, labelSize.width, labelSize.height);
    
    _nameLabel.frame = CGRectMake(0, 1, nameSize.width, nameSize.height);
}

#pragma - class methods for computing sizes based on strings

+ (CGFloat)viewHeightForTranscript:(MessageData *)messageData
{
    CGFloat labelHeight = [VoiceView balloonSizeForLabelSize:[VoiceView labelSizeForString:messageData.message fontSize:MESSAGE_FONT_SIZE]].height;
    if (MESSAGE_DIRECTION_SEND != messageData.direction) {
        // Need to add extra height for display name
        CGFloat nameHeight = [VoiceView labelSizeForString:messageData.senderName fontSize:NAME_FONT_SIZE].height;
        return (labelHeight + nameHeight + BUFFER_WHITE_SPACE - NAME_OFFSET_ADJUST);
    }
    else {
        return (labelHeight + BUFFER_WHITE_SPACE);
    }
}

+ (CGSize)labelSizeForString:(NSString *)string fontSize:(CGFloat)fontSize
{
    return [string boundingRectWithSize:CGSizeMake(DETAIL_TEXT_LABEL_WIDTH, 2000.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil].size;
}

+ (CGSize)balloonSizeForLabelSize:(CGSize)labelSize
{
    CGSize balloonSize;
    
    if (labelSize.height < BALLOON_INSET_HEIGHT) {
        balloonSize.height = BALLOON_MIN_HEIGHT;
    }
    else {
        balloonSize.height = labelSize.height + BALLOON_HEIGHT_PADDING;
    }
    
    balloonSize.width = labelSize.width + BALLOON_WIDTH_PADDING;
    
    return balloonSize;
}

@end
