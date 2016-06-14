//
//  ChannelHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelHandler : NSObject

@property (nonatomic, assign) int currentlyActiveChannelID;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) NSString * userNameInChannel;
@property (nonatomic, strong) Channel *currentlyActiveChannel;

+(ChannelHandler*)sharedHandler;
-(int)getCurrentlyActiveChatroom;
//-(BOOL)isHost;

@end
