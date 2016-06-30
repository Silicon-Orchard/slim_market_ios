//
//  ChannelManager.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChannelManager.h"

@interface ChannelManager ()

@property (nonatomic, strong) NSMutableArray *channelList;
@property (nonatomic, strong) NSMutableArray * acceptedOponentUsers;

@end

@implementation ChannelManager


+ (ChannelManager*)sharedInstance{
    
    static ChannelManager *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[ChannelManager alloc] init];
        
    });
    
    return mySharedInstance;
}

- (instancetype)init {
    
    if(self = [super init]){
        // Do any other initialisation stuff here
        self.channelList = [NSMutableArray new];
        self.acceptedOponentUsers = [NSMutableArray new];

    }
    
    return  self;
}

- (void)setCurrentChannel:(Channel *) channel{

    _currentChannel = channel;
    _currentChannelID = channel.channelID;
    _hostUser = channel.hostUser;
    _isHost = channel.isHost;
}


-(Channel *)getChannel:(int)channelID{
    
    for (Channel * channel in self.channelList) {
        
        if (channel.channelID == channelID) {
            
            return channel;
        }
    }
    
    return nil;
}

-(BOOL)hasFoundChannelWith:(int)channelID{
    
    for (Channel * channel in self.channelList) {
        
        if (channel.channelID == channelID) {
            
            return YES;
        }
    }
    
    return NO;
}

-(void)saveChannel:(Channel *)channel{
    
    [self.channelList addObject:channel];
}

-(void)updateChannel:(Channel *)channel ofChannelID:(int)channelID{
    
    for (int i = 0; i< self.channelList.count; i++) {
        Channel * channel = self.channelList[i];
        
        if(channel.channelID == channelID){
            
            [self.channelList replaceObjectAtIndex:i withObject:channel];
        }
    }
}

-(void)removeChannel:(int)channelID{
    
    
    for (int i = 0; i< self.channelList.count; i++) {
        Channel * channel = self.channelList[i];
        
        if(channel.channelID == channelID){
            
            [self.channelList removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)clearAll {
    
    [self.channelList removeAllObjects];
    
    self.currentChannelID = 0;
    self.isHost = NO;
    self.hostUser = nil;
}


#pragma mark - One to One

- (BOOL)isAcceptedOponentUser:(User *) requesterUser {
    
    for (User *user in self.acceptedOponentUsers) {
        
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            return YES;
        }
    }
    
    return NO;
}

- (void)addOponetUserToAcceptedList:(User *) requesterUser{
    
    if(![self isAcceptedOponentUser:requesterUser]){
        
        [self.acceptedOponentUsers addObject:requesterUser];
    }
}

- (void)setActive:(BOOL)active toUser:(User *)theUser{
    
    theUser.isActive = active;
    
    for (int index= 0; index < self.acceptedOponentUsers.count; index++) {
        
        User *user = self.acceptedOponentUsers[index];
        
        if([user.deviceID isEqualToString:theUser.deviceID] && [user.deviceIP isEqualToString:theUser.deviceIP]){
            
            [self.acceptedOponentUsers replaceObjectAtIndex:index withObject:theUser];
        }
    }
}


- (void)removeOponetUserFromAcceptedList:(User *) requesterUser{
    
    for (int i= 0; i < self.acceptedOponentUsers.count; i++) {
        User *user = self.acceptedOponentUsers[i];
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            [self.acceptedOponentUsers removeObjectAtIndex:i];
        }
    }
    
    //[self.acceptedOponentUsers removeObject:requesterUser];
}

@end
