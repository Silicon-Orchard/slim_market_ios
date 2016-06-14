//
//  ChatHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChatHandler.h"

@implementation ChatHandler

+(ChatHandler*)sharedHandler{
    static ChatHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[ChatHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}


-(void)sendMessage:(NSString *)message{

}

@end
