//
//  MessageData.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

// Enumeration of transcript directions
typedef enum {
    MESSAGE_DIRECTION_SEND = 0,
    MESSAGE_DIRECTION_RECEIVE,
    MESSAGE_DIRECTION_LOCAL // for admin messages. i.e. "left channel"
} MessageDirection;

@interface MessageData : NSObject

// Direction of the transcript

@property (readonly, nonatomic) User *user;
@property (readonly, nonatomic) MessageDirection direction;
@property (nonatomic, readonly) NSString *senderName;
@property (nonatomic, readonly) int type;
@property (nonatomic, readonly) NSString *message;

@property (readonly, nonatomic) NSString *fileName;
@property (readonly, nonatomic) NSProgress *progress;
//@property (readonly, nonatomic) NSString *imageName;
//@property (readonly, nonatomic) NSURL *imageUrl;





//@property (nonatomic, assign) uint16_t port;
//@property (nonatomic, strong) NSString *deviceIPAddress;
//@property (nonatomic, strong) NSString *deviceName;
//@property (nonatomic, strong) NSString *deviceID;
//@property (nonatomic, strong) NSString *clientIP;
//@property (nonatomic, assign) uint16_t clientPort;
//@property (nonatomic, assign) int channelID;


//@"sender": MESSAGE_SENDER_ME,
//@"sender_name": @"Me",
//@"type": MESSAGE_TYPE_TEXT,
//@"message": self.chatTextField.text
//};


// Initializer used for sent/received text messages

- (id)initWithSender:(NSString *)senderName  type:(int)type message:(NSString *)message direction:(MessageDirection)direction;
- (id)initWithSender:(NSString *)senderName  type:(int)type message:(NSString *)message progress:(NSProgress *)progress direction:(MessageDirection)direction;


@end
