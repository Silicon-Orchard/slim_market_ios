//
//  asyncTCPConnectionHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/11/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface asyncTCPConnectionHandler : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *currentTCPSenderSocket;
@property (nonatomic, strong) GCDAsyncSocket *currentTCPListenerSocket;
@property (nonatomic, assign) dispatch_queue_t currentTCPListenerThread;
@property (nonatomic, assign) dispatch_queue_t currentTCPSenderThread;
@property (nonatomic, strong) NSMutableArray *senderSockets;

+(asyncTCPConnectionHandler*)sharedHandler;
-(void)createTCPSenderSocket;
-(void)sendAudioData:(NSData *)audioData toHost:(NSString *)hostAddress toPort:( uint16_t)portAddress;





@end
