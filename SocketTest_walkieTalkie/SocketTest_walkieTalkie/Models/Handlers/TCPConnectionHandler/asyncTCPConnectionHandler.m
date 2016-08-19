//
//  asyncTCPConnectionHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/11/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "asyncTCPConnectionHandler.h"
#import <UIKit/UIKit.h>

@implementation asyncTCPConnectionHandler{
   
}

+(asyncTCPConnectionHandler*)sharedHandler{
    static asyncTCPConnectionHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[asyncTCPConnectionHandler alloc] init];
        
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}


-(void)createTCPSenderSocket{
    
    self.senderSockets = [[NSMutableArray alloc] initWithCapacity:254];
    self.currentTCPSenderThread = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.currentTCPListenerThread = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    self.currentTCPListenerSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.currentTCPListenerSocket.autoDisconnectOnClosedReadStream = NO;
    
    self.currentTCPSenderSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
//    self.currentTCPSenderSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    self.currentTCPSenderSocket.autoDisconnectOnClosedReadStream = NO;


    
    NSError *error = nil;
    if (![self.currentTCPListenerSocket acceptOnPort:WALKIETALKIE_TCP_LISTENER error:&error])
    {
        NSLog(@"Listener Failed With error: %@", error);
    }
    
    
    [self.currentTCPSenderSocket readDataWithTimeout:-1 tag:0];
    
}




-(void)sendAudioData:(NSData *)audioData toHost:(NSString *)hostAddress toPort:( uint16_t)portAddress{
    
    GCDAsyncSocket* senderSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    senderSocket.autoDisconnectOnClosedReadStream = NO;
    
    @synchronized(self.senderSockets)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.senderSockets addObject:senderSocket];
        });
    }
    
    NSError *err = nil;
    if (![senderSocket connectToHost:hostAddress onPort:WALKIETALKIE_TCP_LISTENER error:&err]) {
        
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"Connection Failed With error: %@", err);
        
    } else{
        
        [senderSocket writeData:audioData withTimeout:100 tag:1];
        [senderSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Audio Data writing"
                                                            message: @""
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            
            //[NSThread sleepForTimeInterval:0.01];
            [alert show];

        });
        
    }
    
    [senderSocket readDataWithTimeout:100 tag:0];
//  [self.currentTCPSenderSocket readDataToLength:90000 withTimeout:-1 tag:0];
    
}


-(void)sendFileData:(NSData *)audioData toHost:(NSString *)hostAddress toPort:( uint16_t)portAddress{
    
    GCDAsyncSocket* senderSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    senderSocket.autoDisconnectOnClosedReadStream = NO;
    
    @synchronized(self.senderSockets)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.senderSockets addObject:senderSocket];
        });
    }
    
    NSError *err = nil;
    if (![senderSocket connectToHost:hostAddress onPort:WALKIETALKIE_TCP_LISTENER error:&err]) {
        
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"Connection Failed With error: %@", err);
        
    } else{
        
        [senderSocket writeData:audioData withTimeout:100 tag:1];
        [senderSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
        
        
        NSLog(@"File Data writing");
        
    }
    
    [senderSocket readDataWithTimeout:100 tag:0];
    //  [self.currentTCPSenderSocket readDataToLength:90000 withTimeout:-1 tag:0];
    
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.currentTCPSenderSocket = newSocket;

    NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    
}

  
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Data Sent!");
    [self.currentTCPSenderSocket disconnectAfterWriting];
    
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    NSLog(@"Socket Disconnected with error: %@", [err localizedDescription]);
    
}


- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Data Receieved!");
    NSLog(@"received data Length %lu", (unsigned long)[data length]);
    NSDictionary* userInfo = @{@"receievedData": data};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_TCP_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
    
    [self.currentTCPSenderSocket disconnectAfterReading];

}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connection Established To address %@", host);
    
    [self.currentTCPSenderSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];

}

@end
