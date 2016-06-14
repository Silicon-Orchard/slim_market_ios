//
//  ChannelHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChannelHandler.h"

@implementation ChannelHandler

+(ChannelHandler*)sharedHandler{
    static ChannelHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[ChannelHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

-(int)getCurrentlyActiveChatroom{
    return self.currentlyActiveChannelID;
}

//-(BOOL)isHost{
//    return self.isHost;
//}

@end
