//
//  asyncUDPConnectionHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>


@interface asyncUDPConnectionHandler : NSObject <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *currentListenerSocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *currentVoiceListenerSocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *currentVoiceStreamSocket;


+(asyncUDPConnectionHandler*)sharedHandler;
-(void)createSocketWithPort:(uint16_t) port;
-(void)createVoiceSocketWithPort:(uint16_t) port;
-(void)createVoiceStreamerSocketWithPort:(uint16_t) port;
-(void)sendMessage:(NSString *)message toIPAddress:(NSString *)IPAddress;
-(void)sendVoiceMessage:(NSString *)message toIPAddress:(NSString *)IPAddress;
-(void)sendVoiceStreamData:(NSData *)audioFile toIPAddress:(NSString *)IPAddress;
-(void)enableBroadCast;
-(void)disableBroadCast;


@end
