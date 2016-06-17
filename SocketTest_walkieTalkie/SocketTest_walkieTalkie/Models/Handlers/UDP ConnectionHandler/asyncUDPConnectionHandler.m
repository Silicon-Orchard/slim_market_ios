//
//  asyncUDPConnectionHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "asyncUDPConnectionHandler.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation asyncUDPConnectionHandler

+(asyncUDPConnectionHandler*)sharedHandler{
    static asyncUDPConnectionHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[asyncUDPConnectionHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}


-(void)createSocketWithPort:(uint16_t) port{
    if (self.currentListenerSocket) {
        NSLog(@"SocketNotCreated");
//        self.currentListenerSocket
//        return;
    }
    NSError *error = nil;
    self.currentListenerSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    self.currentListenerSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

//    [self.currentListenerSocket bindToPort:port error:&error];
//    [self.currentListenerSocket setMaxReceiveIPv4BufferSize:65535];
    if (![self.currentListenerSocket bindToPort:WALKIETALKIE_UINT_PORT error:&error]) {
        NSLog(@"bind failed with error %@", [error localizedDescription]);
        //         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };
//    [self.currentListenerSocket enableBroadcast:YES error:&error];
    if (![self.currentListenerSocket beginReceiving:&error]) {
        NSLog(@"receive failed with error %@", [error localizedDescription]);
//         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };
    NSLog(@"SocketCreated!");
}

-(void)createVoiceSocketWithPort:(uint16_t) port{
    if (self.currentListenerSocket) {
        NSLog(@"SocketNotCreated");
        //        self.currentListenerSocket
        //        return;
    }
    NSError *error = nil;
    self.currentVoiceListenerSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //    self.currentListenerSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //    [self.currentListenerSocket bindToPort:port error:&error];
    //    [self.currentListenerSocket setMaxReceiveIPv4BufferSize:65535];
    if (![self.currentVoiceListenerSocket bindToPort:WALKIETALKIE_VOICE_LISTENER error:&error]) {
        NSLog(@"bind failed with error %@", [error localizedDescription]);
        //         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };
    //    [self.currentListenerSocket enableBroadcast:YES error:&error];
    if (![self.currentVoiceListenerSocket beginReceiving:&error]) {
        NSLog(@"receive failed with error %@", [error localizedDescription]);
        //         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };
    NSLog(@"SocketCreated!");
}

-(void)createVoiceStreamerSocketWithPort:(uint16_t) port{
    if (self.currentVoiceStreamSocket) {
        NSLog(@"SocketNotCreated");
    }
    NSError *error = nil;
    self.currentVoiceStreamSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        [self.currentVoiceStreamSocket setMaxReceiveIPv4BufferSize:60535];
    if (![self.currentVoiceStreamSocket bindToPort:WALKIETALKIE_VOICE_STREAMER_PORT error:&error]) {
        NSLog(@"bind failed with error %@", [error localizedDescription]);
    };
    if (![self.currentVoiceStreamSocket beginReceiving:&error]) {
        NSLog(@"receive failed with error %@", [error localizedDescription]);
    };
    NSLog(@"SocketCreated!");
}

-(void)enableBroadCast{
    NSError *error =nil;
    [self.currentListenerSocket enableBroadcast:YES error:&error];
}

-(void)disableBroadCast{
    NSError *error =nil;
    [self.currentListenerSocket enableBroadcast:NO error:&error];
}

-(void)sendMessage:(NSString *)message toIPAddress:(NSString *)IPAddress {
//    NSLog(@"data sent to %@", IPAddress);
     [self.currentListenerSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:IPAddress port:WALKIETALKIE_UINT_PORT withTimeout:3 tag:0];
}

-(void)sendVoiceMessage:(NSString *)message toIPAddress:(NSString *)IPAddress {
    //    NSLog(@"data sent to %@", IPAddress);
    [self.currentVoiceListenerSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:IPAddress port:WALKIETALKIE_VOICE_LISTENER withTimeout:3 tag:0];
}

-(void)sendVoiceStreamData:(NSData *)audioFile toIPAddress:(NSString *)IPAddress {
    NSLog(@"data sent to %@", IPAddress);
    [self.currentVoiceStreamSocket sendData:audioFile toHost:IPAddress port:WALKIETALKIE_VOICE_STREAMER_PORT withTimeout:3 tag:0];
}


/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Datasent");
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Failed");
    
}

/**
 * Called when the socket has received the requested datagram.
 **/


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    
    //NSString *sentdata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //struct sockaddr_in *fromAddressV4 = (struct sockaddr_in *)address.bytes;
    //char *fromIPAddress = inet_ntoa(fromAddressV4 -> sin_addr);
   //NSString *ipAddress = [[NSString alloc] initWithUTF8String:fromIPAddress];
    //uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    
    NSString *hostIP;
    uint16_t senderport;
    int senderSocketFamily;
    [GCDAsyncUdpSocket getHost:&hostIP port:&senderport family:&senderSocketFamily fromAddress:address];
    uint16_t receiverPort = sock.localPort;
   
    NSDictionary* userInfo = @{@"receievedData": data};
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_RECEIVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
       NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
   NSLog(@"received: %@", jsonDict);

    
    
    NSNumber *messageType = [jsonDict objectForKey:JSON_KEY_TYPE];
    NSNumber *channelID  = [jsonDict objectForKey:JSON_KEY_CHANNEL];
    int type = [messageType intValue];
    int channel_id = [channelID intValue];
    
    if (receiverPort == WALKIETALKIE_VOICE_STREAMER_PORT) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
        return;
    }
    else{
        if (!type) {
            [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            return;
        }
    }

    
    switch (type) {
            
        case TYPE_MESSAGE:
            if (channel_id == [ChannelHandler sharedHandler].currentlyActiveChannelID) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CHATMESSAGE_RECEIVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            }
            break;
            
        case TYPE_REQUEST_INFO:
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_DEVICE_CONNECTED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_RECEIVE_INFO:
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_DEVICE_CONFIRMED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_CREATE_CHANNEL:
            [[NSNotificationCenter defaultCenter] postNotificationName:FOREIGN_CHANNEL_CREATED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_JOIN_CHANNEL:
            [[NSNotificationCenter defaultCenter] postNotificationName:JOINCHANNEL_REQUEST_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_CHANNEL_FOUND:
            [[NSNotificationCenter defaultCenter] postNotificationName:JOINCHANNEL_CONFIRM_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_LEFT_CHANNEL:
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANNEL_LEFT_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_LEFT_APPLICATION:
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_LEFT_SYSTEM_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_ONE_TO_ONE_CHAT_REQUEST:
            [[NSNotificationCenter defaultCenter] postNotificationName:ONE_TO_ONE_CHAT_REQUEST_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
        case TYPE_ONE_TO_ONE_CHAT_ACCEPT:
            [[NSNotificationCenter defaultCenter] postNotificationName:ONE_TO_ONE_CHAT_ACCEPT_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_ONE_TO_ONE_CHAT_DECLINE:
            [[NSNotificationCenter defaultCenter] postNotificationName:ONE_TO_ONE_CHAT_DECLINE_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_VOICE_MESSAGE:
            [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_VOICE_MESSAGE_REPEAT_REQUEST:
            [[NSNotificationCenter defaultCenter] postNotificationName:UDP_VOICE_MESSAGE_REPEAR_REQUEST_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_VOICE_STREAM:
            [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        default:
            break;
    }
    

    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"SocketClosed with error %@", [error localizedDescription]);
    self.currentListenerSocket = nil;
    [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    [self createVoiceSocketWithPort:WALKIETALKIE_VOICE_LISTENER];
}


@end
