//
//  Channel.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Channel : NSObject




#pragma mark - Old Setup
@property (nonatomic, assign) int channelID;
@property (nonatomic, strong) NSMutableArray *channelMemberIPs;
@property (nonatomic, strong) NSMutableArray *channelMemberIDs;
@property (nonatomic, strong) NSMutableArray *channelMemberNamess;
@property (nonatomic, strong) NSString *foreignChannelHostIP;
@property (nonatomic, strong) NSString *foreignChannelHostDeviceID;
@property (nonatomic, strong) NSString *foreignChannelHostName;

-(id)initWithChannelID:(int)channelID;
-(void)saveChannel:(Channel *)channelToSave;
-(void)saveForeignChannel:(Channel *)channelToSave;

-(Channel *)geChannel:(int)channelID;
-(Channel *)getForeignChannel:(int)channelID;

-(void)addUserToChannelWithChannelID:(int)channelID userIP:(NSString *)userIP userName:(NSString *)userName userID:(NSString *)userID;

-(void)addUserToForeignChannelWithChannelID:(int)channelID userIP:(NSString *)userIP userName:(NSString *)userName userID:(NSString *)userID;

-(void)replaceForeignChannelOfID:(int)channelID withChannel:(Channel *)channel;
-(void)replaceChannelOfID:(int)channelID withChannel:(Channel *)channel;
-(void)removeChannelWithChannelID:(int)channelID;

@end
