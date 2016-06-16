//
//  MessageHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface MessageHandler : NSObject

@property (nonatomic, strong) NSString *deviceIPAddress;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) int messageTYPE;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) NSString *clientIP;
@property (nonatomic, assign) uint16_t clientPort;
@property (nonatomic, assign) int channelID;

+(MessageHandler*)sharedHandler;
-(NSString *)newChannelCreatedMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel;
-(NSString *)joinChannelCreatedMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel;
-(NSString *)confirmJoiningForChannelID:(int)channelID channelName:(NSString *)channelhostName;
-(NSString *)getUUID;
-(NSString *)getIPAddress;
-(NSString *)createChatMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel chatmessage:(NSString *)message;
-(NSString *)leaveChatMessageWithChannelID:(int)channelID deviceName:(NSString *)deviceNameForChannel;
-(NSString *)requestInfoAtStartMessage;
-(NSString *)acknowledgeDeviceInNetwork;
-(NSString *)leftApplicationMessage;
-(NSString *)voiceMessageJSONStringWithAudioFileName:(NSString *)fileName;
-(NSString *)voiceMessageJSONStringWithAudioFileName:(NSString *)fileName forChannel:(int)channelID;
-(NSArray *)voiceMessageJSONStringInChunksWithAudioFileName:(NSString *)fileName;
-(NSArray *)voiceMessageJSONStringInChunksWithAudioFileName:(NSString *)fileName inChannel:(int)channelID;
-(NSString *)repeatVoiceMessageRequest;
-(NSString *)voiceStreamDataFromAudioBuffer:(NSData *)buffer inChannelID:(int)channelID;

-(NSString *)oneToOneChatRequestMessage;
-(NSString *)oneToOneChatAcceptMessage;
-(NSString *)oneToOneChatDeclineMessage;

@end
